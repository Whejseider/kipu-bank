# KipuBankV3 🏦

[English](#english-version) | [Español](#versión-en-español)

---

## Versión en Español

KipuBankV3 es la evolución del banco descentralizado KipuBank, ahora con integración completa de **Uniswap V2** para soportar depósitos de cualquier token ERC-20. Todos los tokens se convierten automáticamente a USDC y se acreditan en el balance del usuario.

> [!WARNING]
> Se recomienda utilizar redes de prueba como Sepolia. Este contrato es para fines educativos y no ha sido auditado profesionalmente.

### 🚀 Novedades en V3

#### ¿Qué cambió desde V2?

**Antes (V2)**: Solo podías depositar tokens con price feeds de Chainlink (ETH, USDC, DAI, etc.)

**Ahora (V3)**: Deposita **cualquier token** con liquidez en Uniswap V2:
- ✅ ETH, USDC, WETH, WBTC, LINK, UNI, AAVE...
- ✅ Cualquier token ERC-20 con par en Uniswap V2
- ✅ Conversión automática a USDC
- ✅ Sin necesidad de price feeds

#### Mejoras Principales

- 🔄 **Swap automático**: Los tokens se intercambian a USDC dentro del contrato
- 🛣️ **Routing inteligente**: Intenta primero path directo (Token→USDC), luego vía WETH (Token→WETH→USDC)
- 💰 **Contabilidad en USDC**: Todos los balances se manejan en USDC (6 decimales)
- 🔒 **Bank cap respetado**: El límite se verifica DESPUÉS del swap
- 🛡️ **Protección de slippage**: 0.5% de tolerancia en cada swap
- 📊 **Preview de swaps**: Consulta cuánto USDC recibirás antes de depositar

### 📋 Características

#### Depósitos Multi-Token
- **ETH nativo**: Se swapea automáticamente a USDC
- **USDC**: Se deposita directamente sin swap
- **Cualquier ERC-20**: Se swapea a USDC vía Uniswap V2

#### Rutas de Swap Soportadas

El contrato prueba automáticamente dos paths:

1. **Path Directo**: `Token → USDC`
2. **Path via WETH**: `Token → WETH → USDC`

Esto maximiza la compatibilidad con la mayoría de tokens en Uniswap V2.

#### Sistema de Seguridad
- ✅ **ReentrancyGuard**: Protección contra ataques de reentrancia
- ✅ **SafeERC20**: Transferencias seguras de tokens
- ✅ **AccessControl**: Sistema de roles (Admin, Operator)
- ✅ **Pausable**: Mecanismo de pausa de emergencia
- ✅ **Slippage protection**: 0.5% máximo de deslizamiento
- ✅ **Deadline buffer**: 5 minutos para ejecutar swaps

### 📦 Dependencias

El contrato utiliza las siguientes librerías:
- **OpenZeppelin Contracts v5.0.0**: AccessControl, ReentrancyGuard, SafeERC20
- **Uniswap V2**: Router02 para swaps

### 🚀 Despliegue en Remix

#### Paso 1: Preparar el entorno

1. Abrir [Remix IDE](https://remix.ethereum.org/)
2. Crear una nueva carpeta llamada `contracts`
3. Dentro de la carpeta, crear el archivo `KipuBankV3.sol` y pegar el código del contrato

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
```

Remix los descargará automáticamente al compilar.

#### Paso 3: Compilar

1. Ir a la pestaña **"Solidity Compiler"** (icono de S)
2. Seleccionar compiler version: **0.8.30**
3. Click en **"Compile KipuBankV3.sol"**
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

En el campo **Deploy** junto al botón naranja, ingresar los 4 parámetros del constructor:

**Parámetros recomendados para testing:**

```
1000000000, 100000000, 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008, 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
```

**Explicación de los parámetros:**

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `_bankCapUSD` | `1000000000` | Capacidad máxima del banco = **$1,000 USD** (6 decimales) |
| `_withdrawalThresholdUSD` | `100000000` | Límite por retiro = **$100 USD** (6 decimales) |
| `_uniswapRouter` | `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008` | Uniswap V2 Router en Sepolia |
| `_usdc` | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` | USDC en Sepolia |

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

1. Ir a `KipuBankV3.sol` y darle click derecho → `Flatten`
2. Utilizar el contenido de `KipuBankV3_flattened.sol` para verificar el código del contrato en Etherscan
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

##### 2. Depositar USDC

```
Paso 1: Aprobar USDC
- Ir al contrato USDC en Sepolia
- Llamar approve(direccionKipuBank, 100000000) // 100 USDC

Paso 2: Depositar
- En KipuBank, llamar depositUSDC(100000000) // 100 USDC
```

##### 3. Depositar Cualquier Token

```
Ejemplo con WETH:

Paso 1: Aprobar token
- Ir al contrato del token (ej: WETH)
- Llamar approve(direccionKipuBank, 1000000000000000000) // 1 WETH

Paso 2: Depositar
- En KipuBank, llamar depositToken(direccionWETH, 1000000000000000000)
- El contrato swapeará WETH → USDC automáticamente
```

##### 4. Retirar USDC

```
Función: withdraw(cantidad)
```

1. Click en `withdraw`
2. Ingresar cantidad de USDC a retirar
   - Ejemplo: `50000000` = 50 USDC
3. Click en "transact"
4. Confirmar en MetaMask

> [!NOTE]
> Solo puedes retirar hasta el `withdrawalThresholdUSD` por transacción.

#### 📊 Funciones de Lectura (View Functions)

Estas funciones no cuestan gas y solo leen información:

##### `getUserBalance(usuario)`
Retorna el balance del usuario en USDC (6 decimales).

**Ejemplo:**
```
usuario: 0xTU_ADDRESS
Retorna: 100000000 (= 100 USDC)
```

##### `previewETHToUSDC(cantidad)`
Consulta cuánto USDC recibirás por X cantidad de ETH.

**Ejemplo:**
```
cantidad: 1000000000000000000 // 1 ETH
Retorna: ~2000000000 (= ~$2,000 USDC al precio actual)
```

##### `previewTokenToUSDC(token, cantidad)`
Consulta cuánto USDC recibirás por un token.

**Ejemplo:**
```
token: direccionWETH
cantidad: 1000000000000000000 // 1 WETH
Retorna: cantidad esperada en USDC
```

##### Otras funciones de vista
- **`getTotalValueLocked()`**: Total depositado en el banco en USDC
- **`getStatistics()`**: Total de depósitos y retiros realizados
- **`bankCapUSD()`**, **`withdrawalThresholdUSD()`**, **`paused()`**: Variables públicas

#### 🔴 Funciones de Administrador (Solo ADMIN_ROLE)

##### `updateBankCap(nuevoCapUSD)`
Actualiza la capacidad máxima del banco.

**Ejemplo:** Para cambiar a $5,000:
```
nuevoCapUSD: 5000000000
```

##### `updateWithdrawalThreshold(nuevoThresholdUSD)`
Actualiza el límite de retiro por transacción.

**Ejemplo:** Para cambiar a $500:
```
nuevoThresholdUSD: 500000000
```

##### `togglePause()`
Pausa o reanuda el contrato (emergencia).
- Click y confirma
- El estado cambiará entre `paused = true/false`

##### `emergencyWithdraw(token, cantidad)`
Recupera tokens atascados en el contrato.

**Para recuperar ETH:**
```
token: 0x0000000000000000000000000000000000000000
cantidad: cantidadEnWei
```

**Para recuperar tokens ERC-20:**
```
token: direccionDelToken
cantidad: cantidad
```

##### `grantRole(rol, cuenta)`
Asigna un rol a una dirección.

**Ejemplo para agregar un operador:**
```
rol: 0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929
cuenta: 0xDIRECCION_DEL_OPERADOR
```

> [!TIP]
> Para obtener el bytes32 de un rol, puedes llamar a las funciones públicas:
> - `ADMIN_ROLE()` → retorna el hash del rol
> - `OPERATOR_ROLE()` → retorna el hash del rol

### 🔍 Direcciones de Contratos (Sepolia)

| Contrato | Dirección |
|----------|-----------|
| Uniswap V2 Router | `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008` |
| USDC | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` |
| WETH | `0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9` |

### 📐 Arquitectura del Contrato

#### Roles y Permisos

```
DEFAULT_ADMIN_ROLE (Dueño del contrato)
    ├── Asignar/Revocar roles
    └── Control total sobre el sistema
        
ADMIN_ROLE
    ├── Pausar/Despausar contrato
    ├── Actualizar bank cap
    ├── Actualizar withdrawal threshold
    └── Emergency withdraw
    
OPERATOR_ROLE
    ├── (Reservado para futuras funcionalidades)
```

#### Flujo de Depósitos

```
Usuario deposita Token
    ↓
¿Es USDC? → SÍ → Depositar directamente
    ↓ NO
¿Es ETH? → SÍ → Swap ETH→USDC (Uniswap)
    ↓ NO
Swap Token→USDC (Uniswap)
    ↓
Verificar bank cap
    ↓
Actualizar balance en USDC
    ↓
Emitir evento DepositSuccessful
```

#### Lógica de Routing

```
Intentar: Token → USDC (path directo)
    ↓
¿Liquidez? → SÍ → Usar este path
    ↓ NO
Intentar: Token → WETH → USDC
    ↓
¿Liquidez? → SÍ → Usar este path
    ↓ NO
Revertir con NoLiquidityPath()
```

### 🛡️ Seguridad

#### Patrones Implementados

✅ **Checks-Effects-Interactions**: Todas las funciones siguen este patrón  
✅ **ReentrancyGuard**: En todas las funciones públicas de depósito/retiro  
✅ **SafeERC20**: Para transferencias seguras  
✅ **Slippage Protection**: 0.5% máximo en swaps  
✅ **Deadline Protection**: 5 minutos para ejecutar swaps  
✅ **Custom Errors**: Ahorro de gas vs require strings

#### Mitigaciones

✅ Reentrancia  
✅ Integer overflow/underflow (Solidity 0.8.x)  
✅ Transferencias fallidas  
✅ Acceso no autorizado  
✅ Front-running en swaps (slippage + deadline)

#### Riesgos Residuales

⚠️ **Slippage**: Protegido pero puede afectar cantidad recibida  
⚠️ **Liquidez**: Dependencia de liquidez en Uniswap V2  
⚠️ **MEV**: Mitigado pero no eliminado completamente  
⚠️ **Centralización**: Roles administrativos necesarios para operación

### 🎯 Decisiones de Diseño

#### ¿Por qué Uniswap V2?

**V2 es más simple y predecible**:
- Paths fijos (Token→USDC o Token→WETH→USDC)
- Menos complejidad en la implementación
- Suficiente liquidez para testing educativo

#### ¿Por qué almacenar todo en USDC?

**Ventajas**:
- Contabilidad consistente en USD
- Bank cap justo para todos los tokens
- Simplifica la lógica de retiros

**Trade-off**:
- Usuarios reciben USDC, no el token original
- Exposición a volatilidad durante el swap

#### ¿Por qué 0.5% de slippage?

Balance entre:
- Protección contra MEV/front-running
- Suficiente margen para swaps exitosos
- Comparable con DEXs populares

### 🧪 Testing Checklist

Prueba estas funcionalidades antes de producción:

- [ ] Depositar ETH y verificar USDC recibido
- [ ] Depositar USDC directamente
- [ ] Depositar token con path directo (ej: WETH)
- [ ] Depositar token con path via WETH
- [ ] Verificar que bank cap funcione
- [ ] Verificar withdrawal threshold
- [ ] Probar pausar/despausar
- [ ] Preview de swaps con `previewETHToUSDC` y `previewTokenToUSDC`
- [ ] Emergency withdraw
- [ ] Verificar eventos emitidos

### 📚 Recursos

- [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Remix IDE](https://remix.ethereum.org/)
- [Sepolia Etherscan](https://sepolia.etherscan.io)

### 👨‍💻 Autor

**Franco Vallone** - Whejseider  

---

## English Version

KipuBankV3 is the evolution of the KipuBank decentralized bank, now with full **Uniswap V2** integration to support deposits of any ERC-20 token. All tokens are automatically converted to USDC and credited to the user's balance.

> [!WARNING]
> It is recommended to use test networks like Sepolia. This contract is for educational purposes and has not been professionally audited.

### 🚀 What's New in V3

#### What changed from V2?

**Before (V2)**: You could only deposit tokens with Chainlink price feeds (ETH, USDC, DAI, etc.)

**Now (V3)**: Deposit **any token** with liquidity on Uniswap V2:
- ✅ ETH, USDC, WETH, WBTC, LINK, UNI, AAVE...
- ✅ Any ERC-20 token with a pair on Uniswap V2
- ✅ Automatic conversion to USDC
- ✅ No price feeds needed

#### Main Improvements

- 🔄 **Automatic swap**: Tokens are exchanged to USDC within the contract
- 🛣️ **Smart routing**: Tries direct path first (Token→USDC), then via WETH (Token→WETH→USDC)
- 💰 **USDC accounting**: All balances are managed in USDC (6 decimals)
- 🔒 **Bank cap respected**: Limit is verified AFTER the swap
- 🛡️ **Slippage protection**: 0.5% tolerance on each swap
- 📊 **Swap preview**: Check how much USDC you'll receive before depositing

### 📋 Features

#### Multi-Token Deposits
- **Native ETH**: Automatically swapped to USDC
- **USDC**: Deposited directly without swap
- **Any ERC-20**: Swapped to USDC via Uniswap V2

#### Supported Swap Routes

The contract automatically tries two paths:

1. **Direct Path**: `Token → USDC`
2. **Path via WETH**: `Token → WETH → USDC`

This maximizes compatibility with most tokens on Uniswap V2.

#### Security System
- ✅ **ReentrancyGuard**: Protection against reentrancy attacks
- ✅ **SafeERC20**: Safe token transfers
- ✅ **AccessControl**: Role-based system (Admin, Operator)
- ✅ **Pausable**: Emergency pause mechanism
- ✅ **Slippage protection**: 0.5% maximum slippage
- ✅ **Deadline buffer**: 5 minutes to execute swaps

### 📦 Dependencies

The contract uses the following libraries:
- **OpenZeppelin Contracts v5.0.0**: AccessControl, ReentrancyGuard, SafeERC20
- **Uniswap V2**: Router02 for swaps

### 🚀 Deployment on Remix

#### Step 1: Prepare the environment

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Create a new folder called `contracts`
3. Inside the folder, create the file `KipuBankV3.sol` and paste the contract code

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
```

Remix will download them automatically when compiling.

#### Step 3: Compile

1. Go to **"Solidity Compiler"** tab (S icon)
2. Select compiler version: **0.8.30**
3. Click **"Compile KipuBankV3.sol"**
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

In the **Deploy** field next to the orange button, enter the 4 constructor parameters:

**Recommended parameters for testing:**

```
1000000000, 100000000, 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008, 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
```

**Parameter explanation:**

| Parameter | Value | Description |
|-----------|-------|-------------|
| `_bankCapUSD` | `1000000000` | Maximum bank capacity = **$1,000 USD** (6 decimals) |
| `_withdrawalThresholdUSD` | `100000000` | Withdrawal limit = **$100 USD** (6 decimals) |
| `_uniswapRouter` | `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008` | Uniswap V2 Router on Sepolia |
| `_usdc` | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` | USDC on Sepolia |

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

1. Go to `KipuBankV3.sol` and right-click → `Flatten`
2. Use the content of `KipuBankV3_flattened.sol` to verify the contract code on Etherscan
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

##### 2. Deposit USDC

```
Step 1: Approve USDC
- Go to USDC contract on Sepolia
- Call approve(kipuBankAddress, 100000000) // 100 USDC

Step 2: Deposit
- In KipuBank, call depositUSDC(100000000) // 100 USDC
```

##### 3. Deposit Any Token

```
Example with WETH:

Step 1: Approve token
- Go to token contract (e.g., WETH)
- Call approve(kipuBankAddress, 1000000000000000000) // 1 WETH

Step 2: Deposit
- In KipuBank, call depositToken(wethAddress, 1000000000000000000)
- The contract will automatically swap WETH → USDC
```

##### 4. Withdraw USDC

```
Function: withdraw(amount)
```

1. Click `withdraw`
2. Enter amount of USDC to withdraw
   - Example: `50000000` = 50 USDC
3. Click "transact"
4. Confirm in MetaMask

> [!NOTE]
> You can only withdraw up to `withdrawalThresholdUSD` per transaction.

#### 📊 Read Functions (View Functions)

These functions don't cost gas and only read information:

##### `getUserBalance(user)`
Returns the user's balance in USDC (6 decimals).

**Example:**
```
user: 0xYOUR_ADDRESS
Returns: 100000000 (= 100 USDC)
```

##### `previewETHToUSDC(amount)`
Check how much USDC you'll receive for X amount of ETH.

**Example:**
```
amount: 1000000000000000000 // 1 ETH
Returns: ~2000000000 (= ~$2,000 USDC at current price)
```

##### `previewTokenToUSDC(token, amount)`
Check how much USDC you'll receive for a token.

**Example:**
```
token: wethAddress
amount: 1000000000000000000 // 1 WETH
Returns: expected amount in USDC
```

##### Other view functions
- **`getTotalValueLocked()`**: Total deposited in the bank in USDC
- **`getStatistics()`**: Total deposits and withdrawals made
- **`bankCapUSD()`**, **`withdrawalThresholdUSD()`**, **`paused()`**: Public variables

#### 🔴 Administrator Functions (ADMIN_ROLE only)

##### `updateBankCap(newCapUSD)`
Updates the maximum bank capacity.

**Example:** To change to $5,000:
```
newCapUSD: 5000000000
```

##### `updateWithdrawalThreshold(newThresholdUSD)`
Updates the withdrawal limit per transaction.

**Example:** To change to $500:
```
newThresholdUSD: 500000000
```

##### `togglePause()`
Pauses or unpauses the contract (emergency).
- Click and confirm
- The state will toggle between `paused = true/false`

##### `emergencyWithdraw(token, amount)`
Recovers stuck tokens in the contract.

**To recover ETH:**
```
token: 0x0000000000000000000000000000000000000000
amount: amountInWei
```

**To recover ERC-20 tokens:**
```
token: tokenAddress
amount: amount
```

##### `grantRole(role, account)`
Assigns a role to an address.

**Example to add an operator:**
```
role: 0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929
account: 0xOPERATOR_ADDRESS
```

> [!TIP]
> To get the bytes32 of a role, you can call the public functions:
> - `ADMIN_ROLE()` → returns the role hash
> - `OPERATOR_ROLE()` → returns the role hash

### 🔍 Contract Addresses (Sepolia)

| Contract | Address |
|----------|---------|
| Uniswap V2 Router | `0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008` |
| USDC | `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238` |
| WETH | `0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9` |

### 📐 Contract Architecture

#### Roles and Permissions

```
DEFAULT_ADMIN_ROLE (Contract Owner)
    ├── Assign/Revoke roles
    └── Full system control
        
ADMIN_ROLE
    ├── Pause/Unpause contract
    ├── Update bank cap
    ├── Update withdrawal threshold
    └── Emergency withdraw
    
OPERATOR_ROLE
    ├── (Reserved for future functionalities)
```

#### Deposit Flow

```
User deposits Token
    ↓
Is USDC? → YES → Deposit directly
    ↓ NO
Is ETH? → YES → Swap ETH→USDC (Uniswap)
    ↓ NO
Swap Token→USDC (Uniswap)
    ↓
Verify bank cap
    ↓
Update balance in USDC
    ↓
Emit DepositSuccessful event
```

#### Routing Logic

```
Try: Token → USDC (direct path)
    ↓
Liquidity? → YES → Use this path
    ↓ NO
Try: Token → WETH → USDC
    ↓
Liquidity? → YES → Use this path
    ↓ NO
Revert with NoLiquidityPath()
```

### 🛡️ Security

#### Implemented Patterns

✅ **Checks-Effects-Interactions**: All functions follow this pattern  
✅ **ReentrancyGuard**: In all public deposit/withdrawal functions  
✅ **SafeERC20**: For safe transfers  
✅ **Slippage Protection**: 0.5% maximum on swaps  
✅ **Deadline Protection**: 5 minutes to execute swaps  
✅ **Custom Errors**: Gas savings vs require strings

#### Mitigations

✅ Reentrancy  
✅ Integer overflow/underflow (Solidity 0.8.x)  
✅ Failed transfers  
✅ Unauthorized access  
✅ Front-running on swaps (slippage + deadline)

#### Residual Risks

⚠️ **Slippage**: Protected but may affect received amount  
⚠️ **Liquidity**: Dependency on Uniswap V2 liquidity  
⚠️ **MEV**: Mitigated but not completely eliminated  
⚠️ **Centralization**: Administrative roles necessary for operation

### 🎯 Design Decisions

#### Why Uniswap V2?

**V2 is simpler and more predictable**:
- Fixed paths (Token→USDC or Token→WETH→USDC)
- Less implementation complexity
- Sufficient liquidity for educational testing

#### Why store everything in USDC?

**Advantages**:
- Consistent USD accounting
- Fair bank cap for all tokens
- Simplifies withdrawal logic

**Trade-off**:
- Users receive USDC, not the original token
- Exposure to volatility during swap

#### Why 0.5% slippage?

Balance between:
- Protection against MEV/front-running
- Sufficient margin for successful swaps
- Comparable with popular DEXs

### 🧪 Testing Checklist

Test these functionalities before production:

- [ ] Deposit ETH and verify USDC received
- [ ] Deposit USDC directly
- [ ] Deposit token with direct path (e.g., WETH)
- [ ] Deposit token with path via WETH
- [ ] Verify bank cap works
- [ ] Verify withdrawal threshold
- [ ] Test pause/unpause
- [ ] Swap previews with `previewETHToUSDC` and `previewTokenToUSDC`
- [ ] Emergency withdraw
- [ ] Verify emitted events

### 📚 Resources

- [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Remix IDE](https://remix.ethereum.org/)
- [Sepolia Etherscan](https://sepolia.etherscan.io)

### 👨‍💻 Author

**Franco Vallone** - Whejseider  

### 📄 License

MIT License

---

**⚠️ DISCLAIMER**: This contract is part of an educational project. Although it implements standard security patterns, it has NOT been professionally audited and should NOT be used in production with real funds without a complete audit by blockchain security experts