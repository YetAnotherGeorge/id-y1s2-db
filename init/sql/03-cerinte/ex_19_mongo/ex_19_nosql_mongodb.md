# Ex 19 - NoSQL (MongoDB)

## 1) Justificare migrare + scenarii avantajoase

Migrarea partiala catre NoSQL este utila pentru:
- date semi-structurate care evolueaza des (campuri noi fara migrare de schema);
- volum mare de evenimente (log-uri, tick-uri, istoric executii) cu scriere frecventa;
- query-uri centrate pe agregari rapide si scalare orizontala.

In proiect, MongoDB este potrivit pentru:
- istoric extins de preturi/tick-uri;
- evenimente de tranzactionare in timp real;
- profiluri de investitor cu preferinte si metadate variabile.

## 2) Structura bazei NoSQL

Baza: `bursa_nosql`

Colectii:
- `investitori`
  - document: `_id`, `nume`, `prenume`, `email`, `data_inregistrare`, `profil_risc`, `preferinte`
- `simboluri`
  - document: `_id`, `ticker`, `id_companie`, `id_bursa`, `sector`
- `preturi`
  - document: `_id`, `ticker`, `data`, `open`, `close`, `high`, `low`, `volum`
- `ordine_evenimente`
  - document: `_id`, `id_ordin`, `id_portofoliu`, `ticker`, `tip_sens`, `status`, `moment`

## 3) Docker compose + pornire

Fisier stack: `init/sql/03-cerinte/ex_19_mongo/docker-compose.yaml`

Pornire:

```bash
cd init/sql/03-cerinte/ex_19_mongo
docker compose up -d
```

Conectare shell Mongo:

```bash
docker exec -it mongodb-proiect mongosh -u root -p example --authenticationDatabase admin
```

## 4) Comenzi de creare baza/colecții

```javascript
import { MongoClient } from 'mongodb'; // https://www.npmjs.com/package/mongodb

// Connection URL
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);

// Database Name
const dbName = 'id-y1s2-db';
// Use connect method to connect to the server
await client.connect();
console.log('Connected successfully to server');
const db = client.db(dbName);

db.createCollection('investitori');
db.createCollection('simboluri');
db.createCollection('preturi');
db.createCollection('ordine_evenimente');
// ...

db.investitori.createIndex({ email: 1 }, { unique: true });
db.simboluri.createIndex({ ticker: 1 }, { unique: true });
db.preturi.createIndex({ ticker: 1, data: -1 });
db.ordine_evenimente.createIndex({ id_portofoliu: 1, moment: -1 });
// ...
```

## 5) Inserare / modificare / stergere

```javascript
db.investitori.insertOne({
   nume: 'Ionescu',
   prenume: 'Ana',
   email: 'ana.ionescu@example.com',
   data_inregistrare: new Date('2026-03-01T00:00:00Z'),
   profil_risc: 'moderat',
   preferinte: { sectoare: ['Tech', 'Energy'], moneda: 'RON' }
})

db.preturi.insertMany([
   { ticker: 'AAPL', data: new Date('2026-05-28T00:00:00Z'), open: 190, close: 193, high: 194, low: 189, volum: 1200000 },
   { ticker: 'AAPL', data: new Date('2026-05-29T00:00:00Z'), open: 193, close: 191, high: 195, low: 190, volum: 980000 },
   { ticker: 'MSFT', data: new Date('2026-05-29T00:00:00Z'), open: 420, close: 426, high: 427, low: 418, volum: 830000 }
])

db.investitori.updateOne(
   { 
      email: 'ana.ionescu@example.com' 
   },
   {
      $set: { profil_risc: 'ridicat' },
      $push: { 'preferinte.sectoare': 'Healthcare' }
   }
)

db.preturi.deleteOne({ ticker: 'AAPL', data: new Date('2026-05-28T00:00:00Z') })
```

## 6) Interogari cu filtrare si sortare

```javascript
db.preturi.find(
   { ticker: 'AAPL', close: { $gte: 190 } },
   { _id: 0, ticker: 1, data: 1, close: 1, volum: 1 }
).sort({ data: -1 })

db.ordine_evenimente.find(
   { id_portofoliu: 10, status: { $in: ['EXECUTAT', 'PARTIAL_EXECUTAT'] } }
).sort({ moment: -1 }).limit(20)

db.preturi.aggregate([
   { $match: { data: { $gte: new Date('2026-05-01T00:00:00Z') } } },
   { $group: { _id: '$ticker', volum_total: { $sum: '$volum' }, pret_mediu: { $avg: '$close' } } },
   { $sort: { volum_total: -1 } }
])
```
