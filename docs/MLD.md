\# MLD - PetSitter Local



Legende : \*\*gras\*\* = cle primaire, # = cle etrangere



UTILISATEUR (\*\*id\*\*, nom, prenom, email, mot\_de\_passe\_hash, ville, bio, role, date\_inscription)



ANIMAL (\*\*id\*\*, nom, espece, race, consignes, #id\_proprietaire)



DEMANDE\_GARDE (\*\*id\*\*, date\_debut, date\_fin, description, statut, date\_creation, #id\_proprietaire, #id\_animal, #id\_gardien\_valide)



CANDIDATURE (\*\*id\*\*, message, statut, date\_candidature, #id\_demande, #id\_gardien)



AVIS (\*\*id\*\*, note, commentaire, date\_avis, #id\_demande, #id\_auteur, #id\_destinataire)



\## Cles etrangeres



\- ANIMAL.id\_proprietaire -> UTILISATEUR.id

\- DEMANDE\_GARDE.id\_proprietaire -> UTILISATEUR.id

\- DEMANDE\_GARDE.id\_animal -> ANIMAL.id

\- DEMANDE\_GARDE.id\_gardien\_valide -> UTILISATEUR.id (peut etre NULL)

\- CANDIDATURE.id\_demande -> DEMANDE\_GARDE.id

\- CANDIDATURE.id\_gardien -> UTILISATEUR.id

\- AVIS.id\_demande -> DEMANDE\_GARDE.id

\- AVIS.id\_auteur -> UTILISATEUR.id

\- AVIS.id\_destinataire -> UTILISATEUR.id



\## Contraintes



\- email unique dans UTILISATEUR

\- (id\_demande, id\_gardien) unique dans CANDIDATURE : une seule candidature par gardien et par demande

\- (id\_demande, id\_auteur) unique dans AVIS : une seule note par personne et par garde

\- note comprise entre 1 et 5

\- id\_auteur different de id\_destinataire

\- date\_fin superieure ou egale a date\_debut

