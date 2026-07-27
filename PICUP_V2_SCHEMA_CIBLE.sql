/* PICUP 2.0 - Schéma cible V2 (SQL Server)
   Proposition d'architecture. À exécuter dans une base de recette, jamais directement en production.
*/
SET XACT_ABORT ON;
GO

CREATE TABLE dbo.administrateur (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    identifiant NVARCHAR(100) NOT NULL,
    nom NVARCHAR(120) NULL,
    prenom NVARCHAR(120) NULL,
    email NVARCHAR(255) NOT NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_administrateur_est_actif DEFAULT (1),
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_administrateur_cree_le DEFAULT (SYSUTCDATETIME()),
    modifie_le DATETIME2(0) NOT NULL CONSTRAINT DF_administrateur_modifie_le DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_administrateur_identifiant UNIQUE (identifiant),
    CONSTRAINT UQ_administrateur_email UNIQUE (email)
);
GO

CREATE TABLE dbo.statut (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(40) NOT NULL,
    libelle NVARCHAR(100) NOT NULL,
    perimetre VARCHAR(12) NOT NULL,
    ordre_affichage SMALLINT NOT NULL CONSTRAINT DF_statut_ordre DEFAULT (0),
    est_actif BIT NOT NULL CONSTRAINT DF_statut_actif DEFAULT (1),
    CONSTRAINT CK_statut_perimetre CHECK (perimetre IN ('APPLICATION','VERSION')),
    CONSTRAINT UQ_statut_perimetre_code UNIQUE (perimetre, code)
);
GO

CREATE TABLE dbo.phase_version (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(40) NOT NULL,
    libelle NVARCHAR(100) NOT NULL,
    ordre_affichage SMALLINT NOT NULL,
    est_active BIT NOT NULL CONSTRAINT DF_phase_version_active DEFAULT (1),
    CONSTRAINT UQ_phase_version_code UNIQUE (code)
);
GO

CREATE TABLE dbo.domaine_metier (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(20) NOT NULL,
    libelle NVARCHAR(160) NOT NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_domaine_metier_actif DEFAULT (1),
    CONSTRAINT UQ_domaine_metier_code UNIQUE (code)
);
GO

CREATE TABLE dbo.type_fabricant (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(40) NOT NULL,
    libelle NVARCHAR(100) NOT NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_type_fabricant_actif DEFAULT (1),
    CONSTRAINT UQ_type_fabricant_code UNIQUE (code)
);
GO

CREATE TABLE dbo.fabricant (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    type_fabricant_id SMALLINT NOT NULL,
    code NVARCHAR(40) NOT NULL,
    nom NVARCHAR(180) NOT NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_fabricant_actif DEFAULT (1),
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_fabricant_cree DEFAULT (SYSUTCDATETIME()),
    modifie_le DATETIME2(0) NOT NULL CONSTRAINT DF_fabricant_modifie DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_fabricant_type FOREIGN KEY (type_fabricant_id) REFERENCES dbo.type_fabricant(id),
    CONSTRAINT UQ_fabricant_code UNIQUE (code)
);
GO

CREATE TABLE dbo.contact (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    matricule NVARCHAR(30) NULL,
    nom NVARCHAR(160) NOT NULL,
    prenom NVARCHAR(120) NULL,
    email NVARCHAR(255) NULL,
    telephone NVARCHAR(40) NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_contact_actif DEFAULT (1),
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_contact_cree DEFAULT (SYSUTCDATETIME()),
    modifie_le DATETIME2(0) NOT NULL CONSTRAINT DF_contact_modifie DEFAULT (SYSUTCDATETIME())
);
GO
CREATE UNIQUE INDEX UX_contact_matricule ON dbo.contact(matricule) WHERE matricule IS NOT NULL;
CREATE INDEX IX_contact_nom_prenom ON dbo.contact(nom, prenom);
CREATE INDEX IX_contact_email ON dbo.contact(email) WHERE email IS NOT NULL;
GO

CREATE TABLE dbo.role_contact (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(40) NOT NULL,
    libelle NVARCHAR(120) NOT NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_role_contact_actif DEFAULT (1),
    CONSTRAINT UQ_role_contact_code UNIQUE (code)
);
GO

CREATE TABLE dbo.langage_programmation (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(30) NOT NULL,
    nom NVARCHAR(80) NOT NULL,
    est_actif BIT NOT NULL CONSTRAINT DF_langage_actif DEFAULT (1),
    CONSTRAINT UQ_langage_code UNIQUE (code)
);
GO

CREATE TABLE dbo.caisse_regionale (
    id SMALLINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(20) NOT NULL,
    nom NVARCHAR(160) NOT NULL,
    code_mnemonique NVARCHAR(30) NULL,
    est_active BIT NOT NULL CONSTRAINT DF_caisse_active DEFAULT (1),
    CONSTRAINT UQ_caisse_code UNIQUE (code),
    CONSTRAINT UQ_caisse_nom UNIQUE (nom)
);
GO

CREATE TABLE dbo.application (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code_pic NVARCHAR(20) NOT NULL,
    code_maps NVARCHAR(30) NOT NULL,
    code_solution NVARCHAR(30) NULL,
    nom NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    statut_id SMALLINT NOT NULL,
    domaine_pu_id SMALLINT NOT NULL,
    domaine_pp_id SMALLINT NOT NULL,
    premiere_mise_en_production_le DATE NULL,
    decommissionnee_le DATE NULL,
    dependance_externe_commentaire NVARCHAR(1000) NULL,
    lien_irma NVARCHAR(1000) NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_application_cree DEFAULT (SYSUTCDATETIME()),
    modifie_le DATETIME2(0) NOT NULL CONSTRAINT DF_application_modifie DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_application_statut FOREIGN KEY (statut_id) REFERENCES dbo.statut(id),
    CONSTRAINT FK_application_domaine_pu FOREIGN KEY (domaine_pu_id) REFERENCES dbo.domaine_metier(id),
    CONSTRAINT FK_application_domaine_pp FOREIGN KEY (domaine_pp_id) REFERENCES dbo.domaine_metier(id),
    CONSTRAINT UQ_application_code_pic UNIQUE (code_pic),
    CONSTRAINT CK_application_dates CHECK (decommissionnee_le IS NULL OR premiere_mise_en_production_le IS NULL OR decommissionnee_le >= premiere_mise_en_production_le)
);
GO
CREATE INDEX IX_application_nom ON dbo.application(nom);
CREATE INDEX IX_application_statut ON dbo.application(statut_id);
GO

CREATE TABLE dbo.version (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    application_id BIGINT NOT NULL,
    numero NVARCHAR(50) NOT NULL,
    description NVARCHAR(MAX) NOT NULL,
    release_note NVARCHAR(MAX) NULL,
    statut_id SMALLINT NOT NULL,
    phase_version_id SMALLINT NOT NULL,
    fabricant_id BIGINT NOT NULL,
    mise_a_disposition_le DATE NULL,
    mise_en_production_le DATE NULL,
    decommissionnee_le DATE NULL,
    trajectoire_fabrication_url NVARCHAR(1000) NULL,
    informations_techniques NVARCHAR(MAX) NULL,
    est_en_production BIT NOT NULL CONSTRAINT DF_version_prod DEFAULT (0),
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_version_cree DEFAULT (SYSUTCDATETIME()),
    modifie_le DATETIME2(0) NOT NULL CONSTRAINT DF_version_modifie DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_version_application FOREIGN KEY (application_id) REFERENCES dbo.application(id),
    CONSTRAINT FK_version_statut FOREIGN KEY (statut_id) REFERENCES dbo.statut(id),
    CONSTRAINT FK_version_phase FOREIGN KEY (phase_version_id) REFERENCES dbo.phase_version(id),
    CONSTRAINT FK_version_fabricant FOREIGN KEY (fabricant_id) REFERENCES dbo.fabricant(id),
    CONSTRAINT UQ_version_application_numero UNIQUE (application_id, numero),
    CONSTRAINT CK_version_dates CHECK (decommissionnee_le IS NULL OR mise_en_production_le IS NULL OR decommissionnee_le >= mise_en_production_le)
);
GO
CREATE UNIQUE INDEX UX_version_unique_production ON dbo.version(application_id) WHERE est_en_production = 1;
CREATE INDEX IX_version_application ON dbo.version(application_id);
GO

CREATE TABLE dbo.version_contact (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    version_id BIGINT NOT NULL,
    contact_id BIGINT NOT NULL,
    role_contact_id SMALLINT NOT NULL,
    est_principal BIT NOT NULL CONSTRAINT DF_version_contact_principal DEFAULT (0),
    debut_le DATE NULL,
    fin_le DATE NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_version_contact_cree DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_version_contact_version FOREIGN KEY (version_id) REFERENCES dbo.version(id) ON DELETE CASCADE,
    CONSTRAINT FK_version_contact_contact FOREIGN KEY (contact_id) REFERENCES dbo.contact(id),
    CONSTRAINT FK_version_contact_role FOREIGN KEY (role_contact_id) REFERENCES dbo.role_contact(id),
    CONSTRAINT UQ_version_contact UNIQUE (version_id, contact_id, role_contact_id, debut_le),
    CONSTRAINT CK_version_contact_dates CHECK (fin_le IS NULL OR debut_le IS NULL OR fin_le >= debut_le)
);
GO
CREATE UNIQUE INDEX UX_version_contact_principal ON dbo.version_contact(version_id, role_contact_id)
WHERE est_principal = 1 AND fin_le IS NULL;
GO

CREATE TABLE dbo.version_langage (
    version_id BIGINT NOT NULL,
    langage_id SMALLINT NOT NULL,
    version_technique NVARCHAR(60) NULL,
    est_principal BIT NOT NULL CONSTRAINT DF_version_langage_principal DEFAULT (0),
    commentaire NVARCHAR(500) NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_version_langage_cree DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_version_langage PRIMARY KEY (version_id, langage_id),
    CONSTRAINT FK_version_langage_version FOREIGN KEY (version_id) REFERENCES dbo.version(id) ON DELETE CASCADE,
    CONSTRAINT FK_version_langage_langage FOREIGN KEY (langage_id) REFERENCES dbo.langage_programmation(id)
);
GO
CREATE UNIQUE INDEX UX_version_langage_principal ON dbo.version_langage(version_id) WHERE est_principal = 1;
GO

CREATE TABLE dbo.deploiement_version (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    version_id BIGINT NOT NULL,
    caisse_regionale_id SMALLINT NOT NULL,
    mise_a_disposition_le DATE NULL,
    installation_le DATE NULL,
    derniere_connexion_le DATETIME2(0) NULL,
    est_a_jour BIT NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_deploiement_cree DEFAULT (SYSUTCDATETIME()),
    modifie_le DATETIME2(0) NOT NULL CONSTRAINT DF_deploiement_modifie DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_deploiement_version FOREIGN KEY (version_id) REFERENCES dbo.version(id) ON DELETE CASCADE,
    CONSTRAINT FK_deploiement_caisse FOREIGN KEY (caisse_regionale_id) REFERENCES dbo.caisse_regionale(id),
    CONSTRAINT UQ_deploiement_version_caisse UNIQUE (version_id, caisse_regionale_id)
);
GO

CREATE TABLE dbo.dependance_application (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    application_source_id BIGINT NOT NULL,
    application_cible_id BIGINT NOT NULL,
    type_dependance NVARCHAR(80) NULL,
    commentaire NVARCHAR(1000) NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_dependance_cree DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_dependance_source FOREIGN KEY (application_source_id) REFERENCES dbo.application(id),
    CONSTRAINT FK_dependance_cible FOREIGN KEY (application_cible_id) REFERENCES dbo.application(id),
    CONSTRAINT CK_dependance_distincte CHECK (application_source_id <> application_cible_id),
    CONSTRAINT UQ_dependance UNIQUE (application_source_id, application_cible_id)
);
GO

CREATE TABLE dbo.document (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    application_id BIGINT NULL,
    version_id BIGINT NULL,
    categorie NVARCHAR(60) NOT NULL,
    nom_fichier NVARCHAR(255) NOT NULL,
    nom_original NVARCHAR(255) NULL,
    chemin_stockage NVARCHAR(1000) NOT NULL,
    type_mime NVARCHAR(120) NULL,
    taille_octets BIGINT NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_document_cree DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_document_application FOREIGN KEY (application_id) REFERENCES dbo.application(id) ON DELETE CASCADE,
    CONSTRAINT FK_document_version FOREIGN KEY (version_id) REFERENCES dbo.version(id) ON DELETE CASCADE,
    CONSTRAINT CK_document_parent CHECK ((application_id IS NOT NULL AND version_id IS NULL) OR (application_id IS NULL AND version_id IS NOT NULL))
);
GO

CREATE TABLE dbo.journal_action (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    application_id BIGINT NULL,
    version_id BIGINT NULL,
    administrateur_id BIGINT NULL,
    action NVARCHAR(80) NOT NULL,
    commentaire NVARCHAR(1000) NULL,
    donnees_avant NVARCHAR(MAX) NULL,
    donnees_apres NVARCHAR(MAX) NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_journal_cree DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_journal_application FOREIGN KEY (application_id) REFERENCES dbo.application(id),
    CONSTRAINT FK_journal_version FOREIGN KEY (version_id) REFERENCES dbo.version(id),
    CONSTRAINT FK_journal_admin FOREIGN KEY (administrateur_id) REFERENCES dbo.administrateur(id),
    CONSTRAINT CK_journal_cible CHECK (application_id IS NOT NULL OR version_id IS NOT NULL)
);
GO
CREATE INDEX IX_journal_application_date ON dbo.journal_action(application_id, cree_le DESC);
CREATE INDEX IX_journal_version_date ON dbo.journal_action(version_id, cree_le DESC);
GO

CREATE TABLE dbo.trace_connexion (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    identifiant NVARCHAR(100) NOT NULL,
    connecte_le DATETIME2(3) NOT NULL,
    adresse_ip VARCHAR(45) NULL,
    agent_utilisateur NVARCHAR(1000) NULL,
    est_reussie BIT NOT NULL,
    chemin_redirection NVARCHAR(500) NULL
);
GO
CREATE INDEX IX_trace_connexion_date ON dbo.trace_connexion(connecte_le DESC);
CREATE INDEX IX_trace_connexion_identifiant ON dbo.trace_connexion(identifiant);
GO

CREATE TABLE dbo.incident_technique (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    perimetre NVARCHAR(80) NOT NULL,
    severite NVARCHAR(20) NOT NULL,
    type_erreur NVARCHAR(255) NOT NULL,
    message NVARCHAR(2000) NOT NULL,
    details NVARCHAR(MAX) NULL,
    base_disponible BIT NULL,
    cache_utilise BIT NULL,
    donnees_cachees_le DATETIME2(0) NULL,
    cree_le DATETIME2(0) NOT NULL CONSTRAINT DF_incident_cree DEFAULT (SYSUTCDATETIME())
);
GO
CREATE INDEX IX_incident_perimetre_date ON dbo.incident_technique(perimetre, cree_le DESC);
GO
