# Grupo 03 - Megaman


Repositório para o desenvolvimento do projeto de Megaman, do Grupo 3, na disciplina SBD1 com o professor Maurício Serrano.

<p align="center">
    <img src="Assets/mega%20man.gif">
</p>

## Colaboradores

| Nome | Matrícula |
|----|------------|
| [Ailton Aires Amado](https://github.com/ailtonaires) | 18/0011600 |
| [André Lucas](https://github.com/andrelucasf) | 15/0005563 |
| [Daniel Primo](https://github.com/danieldagerom) | 18/0063162 |
| [Wagner M Cunha](https://github.com/wagnermc506) | 18/0029177 |
| [Enzo Gabriel](https://github.com/enzoggqs) | 16/0119006 |

## Entrega Módulo 1 - Modelo Entidade Relacionamento (MER)

Abaixo a última versão do diagrama do Modelo Entidade Relacionamento (v1.0). Todas as versões podem ser encontradas na pasta [MER](./MER).

<p align="center">
    <img src="MER/MER_megaman_mud_v1.0.jpg">
</p>

## Entrega Módulo 2 - Modelo Relacional (MR)

Abaixo a última versão do diagrama do Modelo Relacional (v1.0). Todas as versões podem ser encontradas na pasta [Modelo Relacional](./Modelo_Relacional).
O Modelo Entidade Relacionamento também foi atualizado, e esta entrega usa como base o [MER Versão 1.2](./MER/MER_megaman_mud_v1.2.jpg).

<p align="center">
    <img src="Modelo_Relacional/Modelo_Relacional_v1.0.png">
</p>

## Entrega Módulo 3 - Normalização

Abaixo a última versão do documento de Normalização (v1.0). As outras versões podem ser encontradas na pasta [Normalizacao](./Normalizacao).

<p align="center">
    <img src="Normalizacao/normalizacao_v1.0.jpg">
</p>

## Entrega Módulo 4 - SQL

Este módulo tem como entregáveis:

- O arquivo de [criação de tabelas](SQL/TableCreation.sql);
- O arquivo de [inserção de tuplas](SQL/TuplasCreation.sql); e
- A [implementação inicial do jogo](game).

## Entrega Módulo 5 - Procedures e Triggers

Este módulo tem como entregáveis:

- Os arquivos de [procedures e triggers](https://github.com/SBD1/Grupo03-Megaman/tree/main/SP_e_Triggers);


## Entrega Final

O vídeo de apresentação da entrega final pode ser visto no [youtube](https://youtu.be/k_445DC_LFY), e também pode ser baixado pelo [Google Drive](https://drive.google.com/file/d/1wQDLgmeq7TBbMX5kDYUv8nVOB9_lp5ug/view?usp=sharing).

O jogo (no diretório [game](./game/) foi implementado em python de forma a rodar na linha de comando. As instruções para rodá-lo estão em [game/README.md](./game/README.md).

Antes de rodar o jogo é necesário criar e popular o banco de dados. Com o terminal aberto na pasta raíz deste repositório, entre no psql e use o comando:

```psql
\i run_all.sql
```

Obs.: É necessário que não exista nenhum usuário conectado a um banco de dados chamado `megaman` quando rodar o script. O script recria e popula o banco do zero toda vez que é chamado.
