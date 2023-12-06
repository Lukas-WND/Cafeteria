CREATE DATABASE Cafeteria;

USE Cafeteria;

CREATE TABLE Cliente (
	idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nomeCliente VARCHAR(255),
    emailCliente VARCHAR(255),
    telefoneCliente VARCHAR(11)
);

CREATE TABLE Funcionarios (
	matriculaFuncionario INT PRIMARY KEY AUTO_INCREMENT,
    nomeFuncionario VARCHAR(255) NOT NULL,
    cargoFuncionario VARCHAR(255) NOT NULL
);

CREATE TABLE Produtos (
	idProduto INT PRIMARY KEY AUTO_INCREMENT,
    nomeProduto VARCHAR(255) NOT NULL,
    descricaoProduto VARCHAR(255) NOT NULL,
    precoProduto DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Pedidos (
	idPedido INT PRIMARY KEY AUTO_INCREMENT,
    idCliente INT,
    matriculaFuncionario INT,
    dataHoraPedido DATETIME(2),
    statusPedido VARCHAR(7),
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (matriculaFuncionario) REFERENCES Funcionarios(matriculaFuncionario)
);

CREATE TABLE Detalhes_Pedido (
	idDetalhe INT AUTO_INCREMENT,
	idPedido INT,
    idProduto INT,
    quantidade INT,
    subTotal DECIMAL(10, 2),
    PRIMARY KEY (idDetalhe, idPedido, idProduto),
    FOREIGN KEY (idPedido) REFERENCES Pedidos(idPedido),
    FOREIGN KEY (idProduto) REFERENCES Produtos(idProduto)
);

SELECT * FROM Pedidos WHERE statusPedido = 'aberto' AND idCliente >= 500 ORDER BY idCliente;
SELECT * FROM Detalhes_Pedido;