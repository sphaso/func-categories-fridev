
# Le algebre sono i design pattern della programmazione funzionale
(G. Canti)

Categoria: dato un insieme di oggetti O e un insieme di morfismi M, C(O, M) è una categoria se:
1) per ogni O esiste m in M identità
2) esiste un'operazione di composizione di più morfismi, associativa e per cui esiste sempre un elemento identità

Tradotto per i programmatori: 
oggetti = tipi | morfismi = funzioni
Quando penso a "funtore applicativo" penso alle firme di `<*>` e `pure`, non al loro significato matematico.

Scopo nel modellare: trovare delle strutture algebriche \ categoriali che rappresentano il dominio. Possono essere piccole (lista = monoide) o invadere il codice (parser = monadi). Così facendo:
- codice ordinato in testa ordinata
- più garanzie (so quali funzioni si compongono e quali no)
- @spec si scrive da solo

Tutto questo anche con un linguaggio dinamico! 

Come per i design pattern della OO, non serve conoscere il libro della gang of four, ma conoscerlo aiuta! Non reinventare la ruota ogni volta.
Parto da un'idea: ho due strutture identiche, unisco i valori. Monoide? Semigruppo? ci sono funzioni che si applicano sulla struttura? Funtore! etc. il programma funziona anche se non so cosa è un funtore, ma saperlo diminuisce lo spazio di RAM mentale occupato.

- Setoide: relazione di uguaglianza (esempio: UUID, istanze...)

- Ord: relazione di ordinamento (esempio: colori di quotazione, ruoli in una piattaforma...)

- Semigruppo: elementi che si compongono in maniera associativa, non ho un elemento identità (esempio: concatenazione tra stringhe, somma numerica... "merge" di due oggetti)

- Monoide: un semigruppo con un elemento identità (come sopra, tranne probabilmente per il merge tra oggetti) . Monoide libero: mappiamo la nostra categoria in un monoide più ampio, e.g.: buttiamo stringhe in una lista (esempio Bolla)

- Funtore: "mappa" tra due categorie che ne preserva la struttura(omomorfismo) - esempio: dato un funtore T: A->X, dove A(a, *) e X(b, +) T(a*b) = T(a)+T(b)
esempi: applicazione di funzione ad una lista, applicazione di somma ad un Maybe. a->b viene applicata a F(a) e diventa F(b), firma di fmap è appunto (a->b)->F(a)->F(b) = mappo a su F(a). Preserva la struttura: la mappa delle composizioni è la composizione delle mappe.

- (funtore applicativo, possiamo saltarlo per ora)

- Monadi: niente paura. Modo per comporre funzioni che hanno come codominio elementi di un'altra categoria rispetto a quella di partenza, e.g. f: a -> F(b), g: b -> F(c), come compongo f e g? definisco una funzione che sappia "alzare" g in F(b) -> F(F(c)) e poi abbassi F(F(c)) in F(c).
Gli esempi sono infiniti: parser, IO, maybe...

Da portarsi in saccoccia:
- osservare: provare a pensare a quello che scriviamo in termini di categorie
- usare algebre di base: Maybe in Elixir è {:ok, _} \ {:error, _}. Non buttare ovunque le funzioni "!"
- portare in un unico punto le funzioni che hanno side-effect (non buttare Repo.insert! ad canis verga). Perché?
1) side-effect: funziona impura, se isolo le funzioni impure tutto il resto è puro = facilmente testabile \ ragionabile
2) se uso i maybe posso fare short-circuit della logica molto più facilmente (e.g. with)
3) se spargo "!" e chiamate API senza criterio, ogni funzione diventa monadica, e le monadi ci fanno paura! "inquino" il modello categoriale, più difficile debuggare etc!