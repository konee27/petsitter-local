-- ============================================================
-- PetSitter Local - Script de creation de la base de donnees
-- SGBD vise : MySQL / MariaDB
-- ============================================================

DROP DATABASE IF EXISTS petsitter_local;
CREATE DATABASE petsitter_local CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE petsitter_local;

-- ------------------------------------------------------------
-- Table UTILISATEUR
-- Un utilisateur peut etre proprietaire, gardien ou les deux.
-- ------------------------------------------------------------
CREATE TABLE utilisateur (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    nom               VARCHAR(50)  NOT NULL,
    prenom            VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    ville             VARCHAR(80),
    bio               TEXT,
    role              ENUM('utilisateur', 'admin') NOT NULL DEFAULT 'utilisateur',
    date_inscription  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- Table ANIMAL
-- Chaque animal appartient a un proprietaire.
-- ------------------------------------------------------------
CREATE TABLE animal (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nom             VARCHAR(50) NOT NULL,
    espece          VARCHAR(50) NOT NULL,
    race            VARCHAR(50),
    consignes       TEXT,
    id_proprietaire INT NOT NULL,
    FOREIGN KEY (id_proprietaire) REFERENCES utilisateur(id) ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Table DEMANDE_GARDE
-- id_gardien_valide : un SEUL gardien engage par demande.
-- Il reste NULL tant qu'aucun gardien n'est valide.
-- ------------------------------------------------------------
CREATE TABLE demande_garde (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    date_debut        DATE NOT NULL,
    date_fin          DATE NOT NULL,
    description       TEXT,
    statut            ENUM('publiee', 'pourvue', 'en_cours', 'terminee', 'annulee')
                      NOT NULL DEFAULT 'publiee',
    id_proprietaire   INT NOT NULL,
    id_animal         INT NOT NULL,
    id_gardien_valide INT NULL,
    date_creation     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_proprietaire)   REFERENCES utilisateur(id) ON DELETE CASCADE,
    FOREIGN KEY (id_animal)         REFERENCES animal(id)      ON DELETE CASCADE,
    FOREIGN KEY (id_gardien_valide) REFERENCES utilisateur(id) ON DELETE SET NULL,
    CONSTRAINT chk_dates CHECK (date_fin >= date_debut)
);

-- ------------------------------------------------------------
-- Table CANDIDATURE
-- Un gardien ne peut candidater qu'une fois par demande.
-- ------------------------------------------------------------
CREATE TABLE candidature (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    message            TEXT,
    statut             ENUM('en_attente', 'acceptee', 'refusee') NOT NULL DEFAULT 'en_attente',
    date_candidature   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_demande         INT NOT NULL,
    id_gardien         INT NOT NULL,
    FOREIGN KEY (id_demande)  REFERENCES demande_garde(id) ON DELETE CASCADE,
    FOREIGN KEY (id_gardien)  REFERENCES utilisateur(id)   ON DELETE CASCADE,
    CONSTRAINT uq_candidature UNIQUE (id_demande, id_gardien)
);

-- ------------------------------------------------------------
-- Table AVIS
-- Un auteur ne peut noter qu'une fois par garde.
-- Note de 1 a 5. L'avis n'est autorise qu'apres la fin de la garde
-- (cette regle est verifiee dans le Controller / Model).
-- ------------------------------------------------------------
CREATE TABLE avis (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    note            TINYINT NOT NULL,
    commentaire     TEXT,
    date_avis       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_demande      INT NOT NULL,
    id_auteur       INT NOT NULL,
    id_destinataire INT NOT NULL,
    FOREIGN KEY (id_demande)      REFERENCES demande_garde(id) ON DELETE CASCADE,
    FOREIGN KEY (id_auteur)       REFERENCES utilisateur(id)   ON DELETE CASCADE,
    FOREIGN KEY (id_destinataire) REFERENCES utilisateur(id)   ON DELETE CASCADE,
    CONSTRAINT chk_note        CHECK (note BETWEEN 1 AND 5),
    CONSTRAINT chk_auteur_dest CHECK (id_auteur <> id_destinataire),
    CONSTRAINT uq_avis UNIQUE (id_demande, id_auteur)
);

-- ------------------------------------------------------------
-- Vue : note moyenne et nombre d'avis par utilisateur
-- ------------------------------------------------------------
CREATE VIEW reputation AS
SELECT u.id AS id_utilisateur,
       u.prenom,
       u.nom,
       ROUND(AVG(a.note), 2) AS note_moyenne,
       COUNT(a.id)           AS nombre_avis
FROM utilisateur u
LEFT JOIN avis a ON a.id_destinataire = u.id
GROUP BY u.id, u.prenom, u.nom;

-- ------------------------------------------------------------
-- Jeu de donnees de test (facultatif)
-- ------------------------------------------------------------
INSERT INTO utilisateur (nom, prenom, email, mot_de_passe_hash, ville) VALUES
('Martin', 'Sophie', 'sophie@exemple.fr', 'hash_a_remplacer', 'Creteil'),
('Durand', 'Karim',  'karim@exemple.fr',  'hash_a_remplacer', 'Creteil');

INSERT INTO animal (nom, espece, race, consignes, id_proprietaire) VALUES
('Rex', 'Chien', 'Labrador', 'Deux promenades par jour', 1);

INSERT INTO demande_garde (date_debut, date_fin, description, id_proprietaire, id_animal) VALUES
('2026-11-01', '2026-11-03', 'Garde pour un week-end', 1, 1);

INSERT INTO candidature (message, id_demande, id_gardien) VALUES
('Je suis disponible ce week-end.', 1, 2);
