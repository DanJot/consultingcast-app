CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    pass VARCHAR(255) NOT NULL
);


INSERT INTO users (email, pass) VALUES
('joao@example.com', '12345'),
('maria@example.com', 'abc123'),
('carlos@example.com', 'senhaSegura!'),
('ana@example.com', 'teste123');