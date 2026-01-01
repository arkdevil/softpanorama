
CREATE SCHEMA AUTHORIZATION ABRAXAS

CREATE TABLE S ( SNO    CHAR(5) NOT NULL,
                 SNAME  CHAR(20),
                 STATUS DECIMAL(3),
                 CITY   CHAR(15),
                 UNIQUE (SNO) )

CREATE TABLE P ( PNO    CHAR(6) NOT NULL,
                 PNAME  CHAR(20),
                 COLOR  CHAR(6),
                 WEIGHT DECIMAL(3),
                 CITY   CHAR(15),
                 UNIQUE (PNO) )

CREATE TABLE SP (SNO    CHAR(5) NOT NULL,
                 PNO    CHAR(6) NOT NULL,
                 QTY    DECIMAL(3),
                 UNIQUE (SNO, PNO))

