CREATE DATABASE Cafeteria;

USE Cafeteria;

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

CREATE TABLE Mesas (
	numMesa INT PRIMARY KEY AUTO_INCREMENT,
    capacidade INT NOT NULL,
    statusMesa VARCHAR(15) 
);

CREATE TABLE Clientes (
	idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nomeCliente VARCHAR(255) NOT NULL,
    emailCliente VARCHAR(255),
    telefoneCliente VARCHAR(255),
    numMesa INT,
    FOREIGN KEY (numMesa) REFERENCES Mesas (numMesa)
);

CREATE TABLE Pedidos (
	idPedido INT AUTO_INCREMENT,
    idCliente INT,
    matriculaFuncionario INT,
    dataHoraPedido DATETIME(2),
    statusPedido VARCHAR(7),
    PRIMARY KEY (idPedido, idCliente, matriculaFuncionario),
    FOREIGN KEY (idCliente) REFERENCES Clientes (idCliente),
    FOREIGN KEY (matriculaFuncionario) REFERENCES Funcionarios (matriculaFuncionario)
);

CREATE TABLE Detalhes_Pedido (
	idPedido INT,
    idProduto INT,
    quantidade INT,
    subTotal DECIMAL(10, 2),
    PRIMARY KEY (idPedido, idProduto),
    FOREIGN KEY (idPedido) REFERENCES Pedidos (idPedido),
    FOREIGN KEY (idProduto) REFERENCES Produtos (idProduto)
);

CREATE TABLE Pedidos_Fechados (
	idPedido INT PRIMARY KEY,
    taxaServico DECIMAL(10, 2),
    total DECIMAL (10, 2),
    statusPagamento VARCHAR(15),
    dataHoraFechamento DATETIME(2),
    FOREIGN KEY (idPedido) REFERENCES Detalhes_Pedido (idPedido)
);

DELIMITER //

CREATE TRIGGER tr_dataHora_status_Pedido BEFORE INSERT
ON Pedidos
FOR EACH ROW
BEGIN
	SET NEW.dataHoraPedido = NOW();
    SET NEW.statusPedido = 'aberto';
END;

//

CREATE TRIGGER tr_calcula_subTotal
BEFORE INSERT ON Detalhes_Pedido
FOR EACH ROW
SET NEW.subTotal = (SELECT precoProduto FROM Produtos WHERE idProduto = NEW.idProduto) * NEW.quantidade;

//

CREATE TRIGGER tr_atualiza_subTotal
BEFORE UPDATE ON Detalhes_Pedido
FOR EACH ROW
SET NEW.subTotal = (SELECT precoProduto FROM Produtos WHERE idProduto = NEW.idProduto) * NEW.quantidade;

//

CREATE TRIGGER tr_fecha_pedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF OLD.statusPedido = 'aberto' AND NEW.statusPedido = 'finalizado' THEN
        -- Calcular o total do pedido
        SET @total_pedido := (
            SELECT SUM(dp.subTotal)
            FROM Detalhes_Pedido dp
            WHERE dp.idPedido = NEW.idPedido
        );

        -- Calcular a taxa de serviço (10% do total)
        SET @taxa_servico := @total_pedido * 0.10;

        -- Inserir na tabela Pedidos_Fechados
        INSERT INTO Pedidos_Fechados (idPedido, taxaServico, total, statusPagamento, dataHoraFechamento)
        VALUES (NEW.idPedido, @taxa_servico, @total_pedido, 'aguardando', NULL);

    END IF;
END;

//

CREATE TRIGGER tr_atualiza_dataHoraFechamento
AFTER UPDATE ON Pedidos_Fechados
FOR EACH ROW
BEGIN
    IF OLD.statusPagamento = 'aguardando' AND NEW.statusPagamento = 'finalizado' THEN
        UPDATE Pedidos_Fechados
        SET dataHoraFechamento = NOW()
        WHERE idPedido = NEW.idPedido;
    END IF;
END;

//

DELIMITER ;
