# KipuBank 🏦

[English](#english-version) | [Español](#versión-en-español)

---

## Versión en Español

KipuBank es un contrato inteligente educativo que simula un banco descentralizado multi-token en Ethereum, escrito en Solidity v0.8.30.

> [!WARNING]
> Se recomienda utilizar redes de prueba como Sepolia. Este contrato es para fines educativos y no ha sido auditado profesionalmente.

### 📋 Características

Permite a los usuarios:
- **Depositar y retirar ETH** nativo de forma segura
- **Depositar y retirar tokens ERC-20** (USDC, DAI, etc.)
- **Contabilidad en USD**: Todos los balances se calculan en dólares usando oráculos de Chainlink
- **Límites inteligentes**: Bank cap y withdrawal threshold basados en valor USD real
- **Control de acceso**: Sistema de roles para administradores y operadores
- **Sistema de pausa**: Mecanismo de emergencia para detener operaciones

### 🆕 Mejoras desde V1

- ✅ Control de acceso basado en roles (OpenZeppelin AccessControl)
- ✅ Soporte multi-token (ETH + cualquier ERC20)
- ✅ Integración con Chainlink Price Feeds (conversión a USD)
- ✅ Contabilidad interna normalizada en USD (6 decimales)
- ✅ Protección contra reentrancia (ReentrancyGuard)
- ✅ Sistema de pausa de emergencia
- ✅ Transferencias ERC20 seguras (SafeERC20)
- ✅ Código y documentación en inglés

### 📦 Dependencias

El contrato utiliza las siguientes librerías:
- **OpenZeppelin Contracts v5.0.0**: AccessControl, ReentrancyGuard, SafeERC20
- **Chainlink Contracts v1.0.0**: AggregatorV3Interface

### 🚀 Despliegue en Remix

#### Paso 1: Preparar el entorno

1. Abrir [Remix IDE](https://remix.ethereum.org/)
2. Crear una nueva carpeta llamada `contracts`
3. Dentro de la carpeta, crear el archivo `kipu.sol` y pegar el código del contrato

#### Paso 2: Instalar dependencias

En Remix, las dependencias se importan automáticamente. El contrato usa:

```solidity
/*///////////////////////////////////
        Imports
///////////////////////////////////*/
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/*///////////////////////////////////
        Libraries
///////////////////////////////////*/
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*///////////////////////////////////
        Interfaces
///////////////////////////////////*/
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
```

#### Paso 3: Compilar

1. Ir a la pestaña **"Solidity Compiler"** (icono de S)
2. Seleccionar compiler version: **0.8.30**
3. Click en **"Compile kipu.sol"**
4. Verificar que no haya errores

#### Paso 4: Configurar red y wallet

1. Ir a la pestaña **"Deploy & Run Transactions"** (icono de Ethereum)
2. En **Environment**, seleccionar **"Injected Provider - MetaMask"**
3. Asegurarte de que MetaMask esté en **Sepolia Test Network**
4. Verificar que tengas ETH de prueba en Sepolia

> [!TIP]
> **¿Necesitas ETH de prueba?** Consigue Sepolia ETH gratis en:
> - [Google Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

#### Paso 5: Desplegar el contrato

En el campo **Deploy** junto al botón naranja, ingresar los 3 parámetros del constructor:

**Parámetros recomendados para testing:**

```
1000000000, 100000000, 0x694AA1769357215DE4FAC081bf1f309aDC325306
```

**Explicación de los parámetros:**

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `_bankCapUSD` | `1000000000` | Capacidad máxima del banco = **$1,000 USD** (6 decimales) |
| `_withdrawalThresholdUSD` | `100000000` | Límite por retiro = **$100 USD** (6 decimales) |
| `_ethUsdPriceFeed` | `0x694AA1769357215DE4FAC081bf1f309aDC325306` | Chainlink ETH/USD Price Feed en Sepolia |

**Conversión USD a formato de 6 decimales:**

| USD | Formato (6 decimales) |
|-----|-----------------------|
| $1 | `1000000` |
| $10 | `10000000` |
| $100 | `100000000` |
| $1,000 | `1000000000` |
| $10,000 | `10000000000` |

#### Paso 6: Deploy!

1. Click en **"Deploy"**
2. Confirmar la transacción en MetaMask
3. Esperar la confirmación
4. ¡Contrato desplegado! Aparecerá en "Deployed Contracts"

#### Paso 7: Verificar en Etherscan (Opcional pero recomendado)

1. Ir a `kipu.sol` y darle click derecho → `Flatten`
2. Utilizar el contenido de `kipu_flattened.sol` para verificar el código del contrato en Etherscan
3. Copiar la dirección del contrato desplegado
4. Ir a [Sepolia Etherscan](https://sepolia.etherscan.io)
5. Buscar tu contrato
6. En la pestaña "Contract", click en "Verify and Publish"
7. Completar el formulario:
   - Compiler: `v0.8.30`
   - Optimization: `No`
   - EVM Version to target: `default`

### 💡 Interacción con el Contrato

Una vez desplegado el contrato en Remix, verás todas las funciones disponibles:

#### 🟢 Funciones para Usuarios (Cualquiera puede usar)

##### 1. Depositar ETH

**Opción A: Función `depositETH()`**
1. En el campo **VALUE** (arriba de los botones), poner cantidad a depositar
2. Seleccionar unidad: `Ether` 
3. Ejemplo: `0.1` Ether
4. Click en `depositETH`
5. Confirmar en MetaMask

**Opción B: Envío directo**
- Simplemente enviar ETH a la dirección del contrato desde tu wallet
- Se depositará automáticamente gracias a la función `receive()`

##### 2. Depositar Tokens ERC-20

Primero el administrador debe agregar soporte para el token.

```
Paso 1: Aprobar tokens
- Ir al contrato del token (ej: USDC)
- Llamar approve(direccionKipuBank, cantidad)

Paso 2: Depositar
- En KipuBank, llamar depositToken(direccionToken, cantidad)
```

##### 3. Retirar ETH

```
Función: withdrawETH(cantidad)
```

1. Click en `withdrawETH`
2. Ingresar cantidad en **wei** a retirar
   - Ejemplo: `100000000000000000` = 0.1 ETH
3. Click en "transact"
4. Confirmar en MetaMask

> [!NOTE]
> **Conversión rápida ETH a Wei:**
> - 1 ETH = `1000000000000000000` wei
> - 0.1 ETH = `100000000000000000` wei
> - 0.01 ETH = `10000000000000000` wei

##### 4. Retirar Tokens ERC-20

```
Función: withdrawToken(direccionToken, cantidad)
```

Ejemplo para retirar 100 USDC:
- `direccionToken`: Dirección del contrato USDC
- `cantidad`: `100000000` (100 USDC con 6 decimales)

#### 📊 Funciones de Lectura (View Functions)

Estas funciones no cuestan gas y solo leen información:

- **`getUserBalance(usuario, token)`**: Balance en USD (6 decimales)
- **`getUserBalanceInTokens(usuario, token)`**: Balance en tokens nativos
- **`getTotalValueLocked()`**: Valor total depositado en USD
- **`getETHPrice()`**: Precio actual de ETH desde Chainlink
- **`getStatistics()`**: Número de depósitos y retiros
- **`getTokenConfig(token)`**: Configuración del token
- **`bankCapUSD()`**, **`withdrawalThresholdUSD()`**, **`paused()`**: Variables públicas

#### 🔴 Funciones de Administrador (Solo ADMIN_ROLE)

- **`updateBankCap(nuevoCapUSD)`**: Actualiza capacidad máxima
- **`updateWithdrawalThreshold(nuevoThresholdUSD)`**: Actualiza límite de retiro
- **`togglePause()`**: Pausa/reanuda el contrato
- **`grantRole(rol, cuenta)`**: Asigna roles

#### 🟡 Funciones de Operador (Solo OPERATOR_ROLE)

- **`addToken(direccionToken, decimals, priceFeed)`**: Agrega soporte para token
- **`removeToken(direccionToken)`**: Remueve soporte para token

### 🔍 Direcciones de Chainlink Price Feeds

#### Sepolia Testnet

| Par | Dirección |
|-----|-----------|
| ETH/USD | `0x694AA1769357215DE4FAC081bf1f309aDC325306` |
| USDC/USD | `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E` |
| DAI/USD | `0x14866185B1962B63C3Ea9E03Bc1da838bab34C19` |

🔗 Más price feeds: [Chainlink Data Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)

### 📐 Arquitectura del Contrato

**Roles y Permisos:**

```
DEFAULT_ADMIN_ROLE (Dueño del contrato)
    ├── Asignar/Revocar roles
    └── Control total sobre el sistema
        
ADMIN_ROLE
    ├── Pausar/Despausar contrato
    ├── Actualizar bank cap
    └── Actualizar withdrawal threshold
    
OPERATOR_ROLE
    ├── Agregar tokens soportados
    └── Remover tokens soportados
```

### 🛡️ Seguridad

**Patrones Implementados:**
- Checks-Effects-Interactions
- ReentrancyGuard
- SafeERC20
- AccessControl
- Custom Errors

**Mitigaciones:**
✅ Reentrancia, Integer overflow/underflow, Transferencias fallidas, Acceso no autorizado

**Riesgos residuales:**
⚠️ Dependencia de oráculos, Volatilidad de precios, Centralización de roles

### 👨‍💻 Autor

**Franco Vallone** - Whejseider  
Proyecto final - ETH KIPU Módulo 2: Fundamentos de Solidity

---

## English Version

KipuBank is an educational smart contract that simulates a multi-token decentralized bank on Ethereum, written in Solidity v0.8.30.

> [!WARNING]
> It is recommended to use test networks like Sepolia. This contract is for educational purposes and has not been professionally audited.

### 📋 Features

Allows users to:
- **Deposit and withdraw native ETH** securely
- **Deposit and withdraw ERC-20 tokens** (USDC, DAI, etc.)
- **USD Accounting**: All balances are calculated in dollars using Chainlink oracles
- **Smart Limits**: Bank cap and withdrawal threshold based on real USD value
- **Access Control**: Role-based system for administrators and operators
- **Pause System**: Emergency mechanism to halt operations

### 🆕 Improvements from V1

- ✅ Role-based access control (OpenZeppelin AccessControl)
- ✅ Multi-token support (ETH + any ERC20)
- ✅ Chainlink Price Feeds integration (USD conversion)
- ✅ Internal accounting normalized in USD (6 decimals)
- ✅ Reentrancy protection (ReentrancyGuard)
- ✅ Emergency pause system
- ✅ Safe ERC20 transfers (SafeERC20)
- ✅ Code and documentation in English

### 📦 Dependencies

The contract uses the following libraries:
- **OpenZeppelin Contracts v5.0.0**: AccessControl, ReentrancyGuard, SafeERC20
- **Chainlink Contracts v1.0.0**: AggregatorV3Interface

### 🚀 Deployment on Remix

#### Step 1: Prepare the environment

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Create a new folder called `contracts`
3. Inside the folder, create the file `kipu.sol` and paste the contract code

#### Step 2: Install dependencies

In Remix, dependencies are imported automatically. The contract uses:

```solidity
/*///////////////////////////////////
        Imports
///////////////////////////////////*/
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/*///////////////////////////////////
        Libraries
///////////////////////////////////*/
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*///////////////////////////////////
        Interfaces
///////////////////////////////////*/
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
```

#### Step 3: Compile

1. Go to **"Solidity Compiler"** tab (S icon)
2. Select compiler version: **0.8.30**
3. Click **"Compile kipu.sol"**
4. Verify there are no errors

#### Step 4: Configure network and wallet

1. Go to **"Deploy & Run Transactions"** tab (Ethereum icon)
2. In **Environment**, select **"Injected Provider - MetaMask"**
3. Make sure MetaMask is on **Sepolia Test Network**
4. Verify you have test ETH on Sepolia

> [!TIP]
> **Need test ETH?** Get free Sepolia ETH at:
> - [Google Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

#### Step 5: Deploy the contract

In the **Deploy** field next to the orange button, enter the 3 constructor parameters:

**Recommended parameters for testing:**

```
1000000000, 100000000, 0x694AA1769357215DE4FAC081bf1f309aDC325306
```

**Parameter explanation:**

| Parameter | Value | Description |
|-----------|-------|-------------|
| `_bankCapUSD` | `1000000000` | Maximum bank capacity = **$1,000 USD** (6 decimals) |
| `_withdrawalThresholdUSD` | `100000000` | Withdrawal limit = **$100 USD** (6 decimals) |
| `_ethUsdPriceFeed` | `0x694AA1769357215DE4FAC081bf1f309aDC325306` | Chainlink ETH/USD Price Feed on Sepolia |

**USD to 6 decimal format conversion:**

| USD | Format (6 decimals) |
|-----|-----------------------|
| $1 | `1000000` |
| $10 | `10000000` |
| $100 | `100000000` |
| $1,000 | `1000000000` |
| $10,000 | `10000000000` |

#### Step 6: Deploy!

1. Click **"Deploy"**
2. Confirm transaction in MetaMask
3. Wait for confirmation
4. Contract deployed! It will appear in "Deployed Contracts"

#### Step 7: Verify on Etherscan (Optional but recommended)

1. Go to `kipu.sol` and right-click → `Flatten`
2. Use the content of `kipu_flattened.sol` to verify the contract code on Etherscan
3. Copy the deployed contract address
4. Go to [Sepolia Etherscan](https://sepolia.etherscan.io)
5. Search for your contract
6. In the "Contract" tab, click "Verify and Publish"
7. Complete the form:
   - Compiler: `v0.8.30`
   - Optimization: `No`
   - EVM Version to target: `default`

### 💡 Contract Interaction

Once the contract is deployed on Remix, you'll see all available functions:

#### 🟢 User Functions (Anyone can use)

##### 1. Deposit ETH

**Option A: `depositETH()` function**
1. In the **VALUE** field (above buttons), enter amount to deposit
2. Select unit: `Ether` 
3. Example: `0.1` Ether
4. Click `depositETH`
5. Confirm in MetaMask

**Option B: Direct send**
- Simply send ETH to the contract address from your wallet
- It will be deposited automatically thanks to the `receive()` function

##### 2. Deposit ERC-20 Tokens

First, the administrator must add support for the token.

```
Step 1: Approve tokens
- Go to the token contract (e.g., USDC)
- Call approve(kipuBankAddress, amount)

Step 2: Deposit
- In KipuBank, call depositToken(tokenAddress, amount)
```

##### 3. Withdraw ETH

```
Function: withdrawETH(amount)
```

1. Click `withdrawETH`
2. Enter amount in **wei** to withdraw
   - Example: `100000000000000000` = 0.1 ETH
3. Click "transact"
4. Confirm in MetaMask

> [!NOTE]
> **Quick ETH to Wei conversion:**
> - 1 ETH = `1000000000000000000` wei
> - 0.1 ETH = `100000000000000000` wei
> - 0.01 ETH = `10000000000000000` wei

##### 4. Withdraw ERC-20 Tokens

```
Function: withdrawToken(tokenAddress, amount)
```

Example to withdraw 100 USDC:
- `tokenAddress`: USDC contract address
- `amount`: `100000000` (100 USDC with 6 decimals)

#### 📊 Read Functions (View Functions)

These functions don't cost gas and only read information:

- **`getUserBalance(user, token)`**: Balance in USD (6 decimals)
- **`getUserBalanceInTokens(user, token)`**: Balance in native tokens
- **`getTotalValueLocked()`**: Total value deposited in USD
- **`getETHPrice()`**: Current ETH price from Chainlink
- **`getStatistics()`**: Number of deposits and withdrawals
- **`getTokenConfig(token)`**: Token configuration
- **`bankCapUSD()`**, **`withdrawalThresholdUSD()`**, **`paused()`**: Public variables

#### 🔴 Administrator Functions (ADMIN_ROLE only)

- **`updateBankCap(newCapUSD)`**: Updates maximum capacity
- **`updateWithdrawalThreshold(newThresholdUSD)`**: Updates withdrawal limit
- **`togglePause()`**: Pauses/unpauses the contract
- **`grantRole(role, account)`**: Assigns roles

#### 🟡 Operator Functions (OPERATOR_ROLE only)

- **`addToken(tokenAddress, decimals, priceFeed)`**: Adds token support
- **`removeToken(tokenAddress)`**: Removes token support

### 🔍 Chainlink Price Feed Addresses

#### Sepolia Testnet

| Pair | Address |
|------|---------|
| ETH/USD | `0x694AA1769357215DE4FAC081bf1f309aDC325306` |
| USDC/USD | `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E` |
| DAI/USD | `0x14866185B1962B63C3Ea9E03Bc1da838bab34C19` |

🔗 More price feeds: [Chainlink Data Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)

### 📐 Contract Architecture

**Roles and Permissions:**

```
DEFAULT_ADMIN_ROLE (Contract Owner)
    ├── Assign/Revoke roles
    └── Full system control
        
ADMIN_ROLE
    ├── Pause/Unpause contract
    ├── Update bank cap
    └── Update withdrawal threshold
    
OPERATOR_ROLE
    ├── Add supported tokens
    └── Remove supported tokens
```

### 🛡️ Security

**Implemented Patterns:**
- Checks-Effects-Interactions
- ReentrancyGuard
- SafeERC20
- AccessControl
- Custom Errors

**Mitigations:**
✅ Reentrancy, Integer overflow/underflow, Failed transfers, Unauthorized access

**Residual Risks:**
⚠️ Oracle dependency, Price volatility, Role centralization

### 📚 Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Chainlink Data Feeds](https://docs.chain.link/data-feeds)
- [Remix IDE](https://remix.ethereum.org/)
- [Sepolia Etherscan](https://sepolia.etherscan.io)

### 👨‍💻 Author

**Franco Vallone** - Whejseider  
Final Project - ETH KIPU Module 2: Solidity Fundamentals

### 📄 License

MIT License

---

**⚠️ DISCLAIMER**: This contract is part of an educational project. Although it implements standard security patterns, it has NOT been professionally audited and should NOT be used in production with real funds without a complete audit by blockchain security experts.
