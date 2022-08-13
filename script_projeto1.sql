CREATE SCHEMA projeto_rh;

USE projeto_rh;

CREATE TABLE Candidato(
	id INT NOT NULL AUTO_INCREMENT,
    nome TEXT NOT NULL,
    data_nascimento DATE NOT NULL,
    pis INT NOT NULL,
    cpf INT NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    bairro VARCHAR(45),
    escolaridade TEXT NOT NULL,
    hard_skills TEXT NOT NULL,
    soft_skills TEXT NOT NULL,
    experiencias TEXT NOT NULL,
    PRIMARY KEY (id, pis, cpf)
);

CREATE TABLE Vaga(
	id INT NOT NULL AUTO_INCREMENT,
    cargo TEXT NOT NULL,
    habilidades_min TEXT NOT NULL,
    habilidades_dif TEXT,
    carga_horaria TIME NOT NULL,
    data_abertura DATE NOT NULL UNIQUE,
    tipo_vaga VARCHAR(50) NOT NULL,
    nivel_experiencia TEXT NOT NULL,
    local_trabalho TEXT NOT NULL,
    beneficios TEXT NOT NULL,
    remuneracao FLOAT NOT NULL,
    prioridade_vaga TINYINT NOT NULL,
    data_fechamento DATE NOT NULL,
    nome_empresa VARCHAR(50) NOT NULL,
    PRIMARY KEY (id, tipo_vaga)
);
  
CREATE TABLE Aplicacao(
	id INT NOT NULL AUTO_INCREMENT,
	id_candidato INT NOT NULL,
    id_vaga INT NOT NULL,
    data_aplicacao DATE NOT NULL,
    PRIMARY KEY (id, data_aplicacao),
    FOREIGN KEY (id_candidato)
		REFERENCES candidato(id),
	FOREIGN KEY (id_vaga)
		REFERENCES vaga(id)
);

CREATE TABLE Processo_Seletivo(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    seletiva TINYINT NOT NULL,
    entrevista_rh TINYINT NOT NULL,
    teste_psicologico TINYINT NOT NULL,
	entrevista_setor_responsavel TINYINT NOT NULL,
    data_fechamento DATE
);

CREATE TABLE Admissao(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    carta_proposta TINYINT NOT NULL,
    documentos_contato TINYINT NOT NULL,
    data_admissional DATE, #O nulo significa que a vaga não houve admissão (declinio do candidato)
    id_processo INT NOT NULL,
    FOREIGN KEY (id_processo)
		REFERENCES processo_seletivo(id)
);

CREATE TABLE Empresa(
	id INT NOT NULL PRIMARY KEY,
    nome_empresa TEXT NOT NULL,
    local_unidade TEXT NOT NULL
);

CREATE TABLE Recrutador(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nome TEXT NOT NULL,
    capacitacao TEXT NOT NULL,
    trabalho_ativo TINYINT NOT NULL
);

CREATE TABLE Aplicacao_processo(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_processo INT,
    id_aplicacao INT,
    FOREIGN KEY (id_processo)
		REFERENCES processo_seletivo(id),
	FOREIGN KEY (id_aplicacao)
		REFERENCES aplicacao(id)
);

CREATE TABLE Empresa_Admissao(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	id_empresa INT,
    id_admissao INT,
    FOREIGN KEY (id_empresa)
		REFERENCES empresa(id),
	FOREIGN KEY (id_admissao)
		REFERENCES admissao(id)
);

CREATE TABLE Recrutador_empresa(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_recrutador INT,
    id_empresa INT,
    FOREIGN KEY (id_recrutador)
		REFERENCES recrutador(id),
	FOREIGN KEY (id_empresa)
		REFERENCES empresa(id)
);

CREATE TABLE Vaga_empresa(
	id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_empresa INT,
    id_vaga INT,
    FOREIGN KEY (id_empresa)
		REFERENCES empresa(id),
	FOREIGN KEY (id_vaga)
		REFERENCES vaga(id)
);

-- QUERY REFERENTE A LEAD TIME

SELECT 
	emp.nome_empresa AS NOME_EMPRESA,
    v.tipo_vaga AS TIPO_VAGA,
	ap.data_aplicacao AS DATA_APLICAÇÃO,
    ps.data_fechamento AS DATA_FECHAMENTO,
    ad.data_admissional AS DATA_ADMISSIONAL,
    DAY(ad.data_admissional - v.data_abertura) AS LEAD_TIME_COMPLETO
FROM
	empresa emp
INNER JOIN vaga_empresa ve ON emp.id = ve.id_empresa
INNER JOIN vaga v ON ve.id_vaga = v.id
INNER JOIN empresa_admissao ea ON emp.id = ea.id_empresa
INNER JOIN admissao ad ON ea.id_admissao = ad.id
INNER JOIN processo_seletivo ps ON ad.id_processo = ps.id
INNER JOIN aplicacao_processo apro ON apro.id_processo = ps.id
INNER JOIN aplicacao ap ON ap.id = apro.id_aplicacao;

-- QUERY ADMISSÃO PESSOA

SELECT
	emp.nome_empresa AS NOME_EMPRESA,
    c.nome AS NOME_CANDIDATO,
    v.id AS ID_VAGA,
    v.cargo AS CARGO,
    ad.data_admissional AS DATA_ADMISSIONAL
FROM
	empresa emp
INNER JOIN vaga_empresa ve ON emp.id = ve.id_empresa
INNER JOIN vaga v ON ve.id_vaga = v.id
INNER JOIN empresa_admissao ea ON emp.id = ea.id_empresa
INNER JOIN admissao ad ON ea.id_admissao = ad.id
INNER JOIN processo_seletivo ps ON ad.id_processo = ps.id
INNER JOIN aplicacao_processo apro ON apro.id_processo = ps.id
INNER JOIN aplicacao ap ON ap.id = apro.id_aplicacao
INNER JOIN candidato c ON c.id = ap.id_candidato
WHERE
	ad.data_admissional IS NOT NULL;