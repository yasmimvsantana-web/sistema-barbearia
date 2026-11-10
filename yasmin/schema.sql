-- Modelagem do sistema de barbearia (PostgreSQL)
-- Executar no banco barbearia2_db

DROP TABLE  agendamentos;
DROP TABLE IF EXISTS barbeiro_servico;
DROP TABLE IF EXISTS servicos;
DROP TABLE IF EXISTS barbeiros;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS usuarios;

-- Quem acessa o sistema. A senha fica como hash bcrypt.
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  senha VARCHAR(255) NOT NULL
);

-- Login inicial da tela: admin@barbearia.com / senha123
INSERT INTO usuarios (nome, email, senha) VALUES (
  'Administrador',
  'admin@barbearia.com',
  '$2b$10$.dKEO1PpHHdmckDj20KWIuyb6nWP9rFQyqHVqh9JWgxX3Sq0OMmj6'
);

-- Pessoas atendidas. O CPF é único e a aplicação grava o valor codificado.
CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  cpf VARCHAR(255) NOT NULL UNIQUE,
  telefone VARCHAR(20) NOT NULL
);

CREATE INDEX idx_clientes_nome ON clientes (LOWER(nome));
CREATE INDEX idx_clientes_telefone ON clientes (telefone);

-- Profissionais da barbearia.
CREATE TABLE barbeiros (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  telefone VARCHAR(20) NOT NULL
);

-- Serviços oferecidos. A duração entra no cálculo da agenda.
CREATE TABLE servicos (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  preco NUMERIC(10, 2) NOT NULL CHECK (preco >= 0),
  duracao_minutos INTEGER NOT NULL CHECK (duracao_minutos > 0)
);

-- Um barbeiro oferece vários serviços e um serviço pode ser feito por vários barbeiros.
CREATE TABLE barbeiro_servico (
  barbeiro_id INTEGER NOT NULL REFERENCES barbeiros (id) ON DELETE RESTRICT,
  servico_id INTEGER NOT NULL REFERENCES servicos (id) ON DELETE RESTRICT,
  PRIMARY KEY (barbeiro_id, servico_id)
);

-- Um atendimento liga um cliente, um barbeiro e um serviço em um horário.
-- A agenda é consultada em ordem de data_hora.
CREATE TABLE agendamentos (
  id SERIAL PRIMARY KEY,
  cliente_id INTEGER NOT NULL REFERENCES clientes (id) ON DELETE RESTRICT,
  barbeiro_id INTEGER NOT NULL REFERENCES barbeiros (id) ON DELETE RESTRICT,
  servico_id INTEGER NOT NULL REFERENCES servicos (id) ON DELETE RESTRICT,
  data_hora TIMESTAMP NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'agendado'
    CHECK (status IN ('agendado', 'concluido', 'cancelado'))
);

CREATE INDEX idx_agendamentos_data_hora ON agendamentos (data_hora);
CREATE INDEX idx_agendamentos_barbeiro_horario ON agendamentos (barbeiro_id, data_hora);
