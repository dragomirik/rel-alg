class RelAlgDB {
    constructor() {
        this.dbName = 'RelAlgDB';
        this.dbVersion = 1;
        this.storeName = 'relations';
        this.db = null;
    }

    async init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.dbVersion);

            request.onerror = (event) => {
                console.error('Error opening database:', event.target.error);
                reject(event.target.error);
            };

            request.onsuccess = (event) => {
                this.db = event.target.result;
                console.log('Database opened successfully');
                resolve();
            };

            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                if (!db.objectStoreNames.contains(this.storeName)) {
                    db.createObjectStore(this.storeName, { keyPath: 'name' });
                    console.log('Object store created');
                }
            };
        });
    }

    async saveRelation(relation) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readwrite');
            const store = transaction.objectStore(this.storeName);

            const request = store.put(relation);

            request.onsuccess = () => {
                console.log('Relation saved:', relation.name);
                resolve();
            };

            request.onerror = (event) => {
                console.error('Error saving relation:', event.target.error);
                reject(event.target.error);
            };
        });
    }

    async getAllRelations() {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readonly');
            const store = transaction.objectStore(this.storeName);
            const request = store.getAll();

            request.onsuccess = () => {
                resolve(request.result);
            };

            request.onerror = (event) => {
                console.error('Error getting relations:', event.target.error);
                reject(event.target.error);
            };
        });
    }

    async deleteRelation(name) {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readwrite');
            const store = transaction.objectStore(this.storeName);
            const request = store.delete(name);

            request.onsuccess = () => {
                console.log('Relation deleted:', name);
                resolve();
            };

            request.onerror = (event) => {
                console.error('Error deleting relation:', event.target.error);
                reject(event.target.error);
            };
        });
    }

    async clearAll() {
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction([this.storeName], 'readwrite');
            const store = transaction.objectStore(this.storeName);
            const request = store.clear();

            request.onsuccess = () => {
                console.log('All relations cleared');
                resolve();
            };

            request.onerror = (event) => {
                console.error('Error clearing relations:', event.target.error);
                reject(event.target.error);
            };
        });
    }
}

// Initialize database
const db = new RelAlgDB();
let dbInitialized = false;

// Handle data persistence
document.addEventListener('DOMContentLoaded', async () => {
    try {
        await db.init();
        dbInitialized = true;
        console.log('IndexedDB initialized');
        
        // Load data from IndexedDB on page load
        const relations = await db.getAllRelations();
        if (relations.length > 0) {
            await fetch('/data/restore', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ relations })
            });
            console.log('Relations restored from IndexedDB');
        }
    } catch (error) {
        console.error('Failed to initialize IndexedDB:', error);
    }
});

// Clean data by removing trailing spaces and empty lines
function cleanData(text) {
    return text
        .split('\n')
        .map(line => line.trimRight())  // Remove trailing spaces
        .filter(line => line.length > 0) // Remove empty lines
        .join('\n');
}

// Intercept form submissions
document.addEventListener('submit', async (event) => {
    const form = event.target;
    if (form.matches('form[action^="/data/"]')) {
        event.preventDefault();
        
        try {
            const formData = new FormData(form);
            
            // Clean schema and rows data
            if (formData.has('schema')) {
                formData.set('schema', cleanData(formData.get('schema')));
            }
            if (formData.has('rows')) {
                formData.set('rows', cleanData(formData.get('rows')));
            }

            const response = await fetch(form.action, {
                method: form.method,
                body: formData
            });

            if (response.ok) {
                const result = await response.json();
                if (result.success) {
                    // Update IndexedDB
                    if (result.relation) {
                        await db.saveRelation(result.relation);
                    }
                    if (result.deletedRelation) {
                        await db.deleteRelation(result.deletedRelation);
                    }
                    // Redirect or reload page
                    window.location.href = result.redirect || '/data';
                } else {
                    // Handle validation errors
                    console.error('Form validation failed:', result.errors);
                    // You might want to display these errors in the UI
                }
            } else {
                console.error('Server error:', response.statusText);
            }
        } catch (error) {
            console.error('Error submitting form:', error);
        }
    }
});
