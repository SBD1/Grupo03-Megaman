### Visão Geral

Como a aplicação é executada na linha de comando, é mais simples executá-la no ambiente local. E por isso a aplicação não fora Containerizada.

### Requisitos

- python 3.8+
- pip

### Ambiente

Primeiramente, configure a conexão com o banco de dados no arquivo `dev.env`. Edite as variáveis e renomeie o arquivo para `.env`.

Recomenda-se usar o venv (virtual env) para rodar a aplicação.

Para criar a pasta venv, utilize o comando:

```shell
$ python -m venv venv
```

e para configurar o ambiente:

```shell
$ source venv/bin/activate
```

### Dependências

Para instalar as dependências, utilize o comando:

```shell
$ pip install -r requirements.txt
```

### Como executar

Para rodar o jogo, inicie o arquivo `src/main.py`:

```shell
$ python src/main.py
```

### Controles

Os controles disponíveis no jogo pode ser vistos ao digitar help.

Em alguns casos o comando não estará disponível, mas o prompt descreverá os comandos disponíveis.