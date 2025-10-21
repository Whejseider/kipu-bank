# KipuBank

KipuBank es un contrato inteligente educativo que simula un banco descentralizado multi-token en Ethereum, escrito en Solidity v0.8.30.

> [!WARNING]
> Se recomienda utilizar redes de prueba como Sepolia. Este contrato es para fines educativos y no ha sido auditado profesionalmente.

## 📋 Características

Permite a los usuarios:
- **Depositar y retirar ETH** nativo de forma segura
- **Depositar y retirar tokens ERC-20** (USDC, DAI, etc.)
- **Contabilidad en USD**: Todos los balances se calculan en dólares usando oráculos de Chainlink
- **Límites inteligentes**: Bank cap y withdrawal threshold basados en valor USD real
- **Control de acceso**: Sistema de roles para administradores y operadores
- **Sistema de pausa**: Mecanismo de emergencia para detener operaciones

## 🆕 Mejoras desde V1

- ✅ Control de acceso basado en roles (OpenZeppelin AccessControl)
- ✅ Soporte multi-token (ETH + cualquier ERC20)
- ✅ Integración con Chainlink Price Feeds (conversión a USD)
- ✅ Contabilidad interna normalizada en USD (6 decimales)
- ✅ Protección contra reentrancia (ReentrancyGuard)
- ✅ Sistema de pausa de emergencia
- ✅ Transferencias ERC20 seguras (SafeERC20)
- ✅ Código y documentación en inglés

## 📦 Dependencias

El contrato utiliza las siguientes librerías:
- **OpenZeppelin Contracts v5.0.0**: AccessControl, ReentrancyGuard, SafeERC20
- **Chainlink Contracts v1.0.0**: AggregatorV3Interface

## 🚀 Despliegue en Remix

### Paso 1: Preparar el entorno

1. Abrir [Remix IDE](https://remix.ethereum.org/)
2. Crear una nueva carpeta llamada `contracts`
3. Dentro de la carpeta, crear el archivo `kipu.sol` y pegar el código del contrato

### Paso 2: Instalar dependencias

En Remix, las dependencias se importan automáticamente desde GitHub. El contrato usa:

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

Remix los descargará automáticamente al compilar.

### Paso 3: Compilar

1. Ir a la pestaña **"Solidity Compiler"** (icono de S)
2. Seleccionar compiler version: **0.8.30**
3. Click en **"Compile kipu.sol"**
4. Verificar que no haya errores

### Paso 4: Configurar red y wallet

1. Ir a la pestaña **"Deploy & Run Transactions"** (icono de Ethereum)
2. En **Environment**, seleccionar **"Injected Provider - MetaMask"**
3. Asegurarte de que MetaMask esté en **Sepolia Test Network**
4. Verificar que tengas ETH de prueba en Sepolia

> [!TIP]
> **¿Necesitas ETH de prueba?** Consigue Sepolia ETH gratis en:
> - [Google Sepolia Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

### Paso 5: Desplegar el contrato

En el campo **Deploy** junto al botón naranja, debes ingresar los 3 parámetros del constructor:

#### Parámetros recomendados para testing:

```
1000000000, 100000000, 0x694AA1769357215DE4FAC081bf1f309aDC325306
```

**Explicación de los parámetros:**

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| `_bankCapUSD` | `1000000000` | Capacidad máxima del banco = **$1,000 USD** (6 decimales) |
| `_withdrawalThresholdUSD` | `100000000` | Límite por retiro = **$100 USD** (6 decimales) |
| `_ethUsdPriceFeed` | `0x694AA1769357215DE4FAC081bf1f309aDC325306` | Chainlink ETH/USD Price Feed en Sepolia |

#### Conversión USD a formato de 6 decimales:

| USD | Formato (6 decimales) |
|-----|-----------------------|
| $1 | `1000000` |
| $10 | `10000000` |
| $100 | `100000000` |
| $1,000 | `1000000000` |
| $10,000 | `10000000000` |

### Paso 6: Deploy!

1. Click en **"Deploy"**
2. Confirmar la transacción en MetaMask
3. Esperar la confirmación
4. ¡Contrato desplegado! Aparecerá en "Deployed Contracts"

### Paso 7: Verificar en Etherscan (Opcional pero recomendado)

1. Ir a `kipu.sol` y darle click derecho `Flatten`
2. Utilizar el contenido de `kipu_flattened.sol` para verificar el código del contrato en Etherscan
3. Copiar la dirección del contrato desplegado
4. Ir a [Sepolia Etherscan](https://sepolia.etherscan.io)
5. Buscar tu contrato
6. En la pestaña "Contract", click en "Verify and Publish"
7. Completar el formulario:
   - Compiler: `v0.8.30`
   - Optimization: `No`
   - EVM Version to target: default

## 💡 Interacción con el Contrato

Una vez desplegado el contrato en Remix, verás todas las funciones disponibles:

### 🟢 Funciones para Usuarios (Cualquiera puede usar)

#### 1. Depositar ETH

**Opción A: Función `depositETH()`**
1. En el campo **VALUE** (arriba de los botones), poner cantidad a depositar
2. Seleccionar unidad: `Ether` 
3. Ejemplo: `0.1` Ether
4. Click en `depositETH`
5. Confirmar en MetaMask

**Opción B: Envío directo**
- Simplemente enviar ETH a la dirección del contrato desde tu wallet
- Se depositará automáticamente gracias a la función `receive()`

#### 2. Depositar Tokens ERC-20

Primero el administrador debe agregar soporte para el token (ver sección Admin).

```
Paso 1: Aprobar tokens
- Ir al contrato del token (ej: USDC)
- Llamar approve(direccionKipuBank, cantidad)

Paso 2: Depositar
- En KipuBank, llamar depositToken(direccionToken, cantidad)
```

#### 3. Retirar ETH

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

#### 4. Retirar Tokens ERC-20

```
Función: withdrawToken(direccionToken, cantidad)
```

Ejemplo para retirar 100 USDC:
- `direccionToken`: Dirección del contrato USDC
- `cantidad`: `100000000` (100 USDC con 6 decimales)

### 📊 Funciones de Lectura (View Functions)

Estas funciones no cuestan gas y solo leen información:

#### `getUserBalance(usuario, token)`
Retorna el balance del usuario en USD (6 decimales) para un token específico.

**Ejemplo:**
```
usuario: 0xTU_ADDRESS
token: 0x0000000000000000000000000000000000000000 (para ETH)
```

#### `getUserBalanceInTokens(usuario, token)`
Retorna el balance convertido a la cantidad de tokens nativos.

#### `getTotalValueLocked()`
Retorna el valor total depositado en el banco en USD.

#### `getETHPrice()`
Retorna el precio actual de ETH en USD desde Chainlink.

#### `getStatistics()`
Retorna el número total de depósitos y retiros realizados.

#### `getTokenConfig(token)`
Retorna la configuración de un token (si está soportado, decimales, price feed).

#### `bankCapUSD()`, `withdrawalThresholdUSD()`, `paused()`
Variables públicas que se pueden consultar directamente.

### 🔴 Funciones de Administrador (Solo ADMIN_ROLE)

#### `updateBankCap(nuevoCapUSD)`
Actualiza la capacidad máxima del banco.

**Ejemplo:** Para cambiar a $5,000:
```
nuevoCapUSD: 5000000000
```

#### `updateWithdrawalThreshold(nuevoThresholdUSD)`
Actualiza el límite de retiro por transacción.

**Ejemplo:** Para cambiar a $500:
```
nuevoThresholdUSD: 500000000
```

#### `togglePause()`
Pausa o reanuda el contrato (emergencia).
- Click y confirma
- El estado cambiará entre `paused = true/false`

#### `grantRole(rol, cuenta)`
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

### 🟡 Funciones de Operador (Solo OPERATOR_ROLE)

#### `addToken(direccionToken, decimals, priceFeed)`
Agrega soporte para un nuevo token ERC-20.

**Ejemplo para agregar USDC en Sepolia:**
```
direccionToken: 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8 (USDC Sepolia)
decimals: 6
priceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E (USDC/USD Sepolia)
```

#### `removeToken(direccionToken)`
Remueve el soporte para un token.

> [!WARNING]
> No se puede remover el token nativo (ETH)

## 🔍 Direcciones de Chainlink Price Feeds

### Sepolia Testnet

| Par | Dirección |
|-----|-----------|
| ETH/USD | `0x694AA1769357215DE4FAC081bf1f309aDC325306` |
| USDC/USD | `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E` |
| DAI/USD | `0x14866185B1962B63C3Ea9E03Bc1da838bab34C19` |

### Ethereum Mainnet

| Par | Dirección |
|-----|-----------|
| ETH/USD | `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419` |
| USDC/USD | `0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6` |
| DAI/USD | `0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9` |

🔗 Más price feeds: [Chainlink Data Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)

## 📐 Arquitectura del Contrato

### Roles y Permisos

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

### Flujo de Depósitos

```
Usuario deposita → Convierte a USD (Chainlink) → Verifica bank cap 
→ Actualiza balance en USD → Emite evento → Transferencia exitosa
```

### Flujo de Retiros

```
Usuario retira → Convierte a USD → Verifica threshold → Verifica balance
→ Actualiza estado → Transfiere tokens/ETH → Emite evento
```

## 🛡️ Seguridad

### Patrones Implementados

- **Checks-Effects-Interactions**: Validaciones → Estado → Interacciones externas
- **ReentrancyGuard**: Protección contra ataques de reentrancia
- **SafeERC20**: Manejo seguro de tokens ERC-20
- **AccessControl**: Control de acceso granular
- **Pausable**: Sistema de pausa de emergencia
- **Custom Errors**: Ahorro de gas vs `require` strings

### Consideraciones de Seguridad

✅ **Mitigado:**
- Reentrancia
- Integer overflow/underflow (Solidity 0.8.x)
- Transferencias fallidas
- Acceso no autorizado

⚠️ **Riesgos residuales:**
- Dependencia de oráculos Chainlink
- Volatilidad de precios afecta balances en USD
- Centralización de roles administrativos

## 🧪 Testing

Se recomienda probar las siguientes funcionalidades:

- [ ] Depositar ETH
- [ ] Retirar ETH
- [ ] Agregar token ERC-20 como operador
- [ ] Depositar token ERC-20
- [ ] Retirar token ERC-20
- [ ] Verificar que bank cap funcione
- [ ] Verificar que withdrawal threshold funcione
- [ ] Pausar y despausar contrato
- [ ] Verificar conversión de precios con Chainlink
- [ ] Probar funciones de lectura

## 🤝 Decisiones de Diseño

### ¿Por qué almacenar balances en USD?

**Ventaja**: Límites justos y consistentes para todos los tokens.  
**Trade-off**: Los usuarios asumen riesgo de volatilidad de precio.

### ¿Por qué usar 6 decimales (USDC)?

**Razón**: Estándar de mercado, suficiente precisión, eficiente en gas.

### ¿Por qué mappings anidados?

```solidity
mapping(address => mapping(address => uint256))
```

**Razón**: Acceso directo y eficiente en gas vs structs complejos.

## 📚 Recursos

- [Documentación Solidity](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Chainlink Data Feeds](https://docs.chain.link/data-feeds)
- [Remix IDE](https://remix.ethereum.org/)
- [Sepolia Etherscan](https://sepolia.etherscan.io)

## 👨‍💻 Autor

**Franco Vallone** - Whejseider  
Proyecto final - ETH KIPU Módulo 2: Fundamentos de Solidity

## 📄 Licencia

MIT License

---

**⚠️ DISCLAIMER**: Este contrato es parte de un proyecto educativo. Aunque implementa patrones de seguridad estándar, NO ha sido auditado profesionalmente y NO debe usarse en producción con fondos reales sin una auditoría completa por expertos en seguridad blockchain.
