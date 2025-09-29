# KipuBank

KipuBank es un contrato inteligente con fines educativo que simula un banco simple en Ethereum, escrito hecho en Solidity v0.8.30.

>[!WARNING]
Se recomienda utilizar redes de prueba como Sepolia.

Permite a los usuarios:
- Depositar fondos respetando el tope máximo del banco.
- Retirar fondos respetando un umbral mínimo.
- Consultar la cantidad de depósitos y retiros realizados.
- Consultar los fondos disponibles, el umbral máximo de retiro y la capacidad máxima de fondos del banco.

## Despliegue

1. Abrir [Remix](https://remix.ethereum.org/).
2. Crear un nuevo archivo `KipuBank.sol` y pegar el código del contrato.
3. Compilar el contrato usando el compilador 0.8.30.
4. Ir a la pestaña "Deploy & Run Transactions".
5. Seleccionar la red Sepolia o cualquier testnet.
6. En el constructor, asignar:
   - `bankCap`: 1 ether → `1000000000000000000` wei
   - `umbralRetiro`: 0.01 ether → `10000000000000000` wei
7. Hacer click en **Deploy**.
8. Acceder a la dirección del contrato desplegado a través de por ejemplo [Sepolia Etherscan](https://sepolia.etherscan.io).

## Interacción

Utilizando Remix (o alguna web que permita ver e interactuar con el contrato).

Una vez deployado el contrato:

- Para depositar fondos:
  1. Seleccionar la función `deposito()`.
  2. Poner un valor en **ETH** o en **WEI**  y hacer click en **Transact**.

- Para retirar fondos:
  1. Seleccionar la función `retiro(uint256 cantidad)`.
  2. Especificar la cantidad a retirar en **wei**.
  3. Click en **Transact**.

- Para Lectura de datos:
  - `verRegistros()` devuelve registro de los números de depósitos y retiros realizados.
  - `verDepositosTotales()` devuelve el valor total de los depósitos.
  - `verUmbralDeRetiro()` devuelve el umbral de retiro.
  - `verBankCap()` devuelve el bankCap.
  - `balanceUsuario(address usuario)` devuelve el balance o fondo del usuario, donde address usuario es la dirección de la wallet del usuario.

## Contrato desplegado en una testnet

A continuación se deja el enlace al [contrato](https://sepolia.etherscan.io/address/0x890fdd0a27f1dd2dd2dc39f6ea86c6d4da7d6fb1) desplegado en el explorador de bloques de Etherscan.
Se puede observar tanto las transacciones como el contrato en sí junto con su código verificado y los eventos.
