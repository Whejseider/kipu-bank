# Informe de Análisis de Amenazas y Preparación para Auditoría - KipuBankV3

---

## 1. Descripción General del Protocolo

**KipuBankV3** es un contrato inteligente tipo "bóveda" (vault) que permite a los usuarios depositar liquidez y mantener un saldo denominado en **USDC**. La innovación principal de esta versión es la integración con **Uniswap V2**, permitiendo la abstracción de depósitos:

* **Depósitos Multimoneda:** Los usuarios pueden depositar ETH (nativo) o cualquier token ERC20.
* **Auto-Swap:** El contrato intercambia automáticamente los activos depositados por USDC utilizando el Router de Uniswap V2.
* **Contabilidad Interna:** Los saldos se registran en una estructura interna (`vaults`) denominada en USDC.
* **Gestión de Riesgos:** Implementa un límite máximo de capacidad (`bankCapUSD`) y un umbral de retiro (`withdrawalThresholdUSD`).

---

## 2. Evaluación de Madurez del Protocolo

El protocolo se encuentra en etapa de **Candidato a Lanzamiento**, pero requiere acciones específicas para alcanzar la madurez de producción según los estándares de seguridad:

* **Cobertura de Pruebas:**
    * *Estado actual:* Se cuenta con pruebas unitarias funcionales.
    * *Faltante:* Pruebas de integración en un entorno bifurcado (forked mainnet) para validar la interacción real con los pools de liquidez de Uniswap.
* **Documentación:**
    * El código utiliza NatSpec para documentar funciones y errores.
    * *Faltante:* Diagrama de arquitectura y documentación de usuario sobre los riesgos de deslizamiento (slippage).
* **Roles y Poderes:**
    * **ADMIN_ROLE:** Posee control centralizado crítico. Puede pausar el contrato, cambiar el Bank Cap y, lo más riesgoso, realizar retiros de emergencia de cualquier activo.
    * **OPERATOR_ROLE:** Definido en el sistema de AccessControl pero actualmente sus permisos se solapan con los del admin.
* **Métodos de Prueba:** Falta la implementación de **Fuzzing** (pruebas difusas) para validar matemáticamente los invariantes del sistema.

---

## 3. Vectores de Ataque y Modelo de Amenazas

Se han identificado tres escenarios de riesgo principales basados en la lógica actual:

### A. Centralización y Riesgo de Custodia (Privilege Escalation / Rug Pull)
* **Tipo:** Falta de Control de Acceso / Abuso de Privilegios.
* **Descripción:** La función `emergencyWithdraw` permite al administrador retirar *cualquier* token o ETH del contrato.
* **Escenario de Ataque:** Un administrador malicioso (o si su clave privada es robada) llama a esta función pasando la dirección del contrato `usdc`.
* **Impacto:** **CRÍTICO**. Permite drenar la totalidad de los fondos que respaldan los depósitos de los usuarios, dejando el banco insolvente.

### B. Denegación de Servicio (DoS) por Deslizamiento Rígido
* **Tipo:** Lógica de Negocio / Parámetros Rígidos.
* **Descripción:** La tolerancia al deslizamiento (`SLIPPAGE_TOLERANCE`) está fija (hardcoded) en `50` (0.5%).
* **Escenario de Ataque:** En momentos de alta volatilidad o baja liquidez, el precio real puede variar más de un 0.5% durante la ejecución. Uniswap revertirá la transacción.
* **Impacto:** **MEDIO**. Los usuarios no podrán depositar fondos legítimamente. Un atacante también podría manipular levemente el pool (Front-running) para forzar que las transacciones de otros fallen.

### C. Dependencia de Liquidez Externa
* **Tipo:** Abuso de Supuestos del Protocolo.
* **Descripción:** El contrato asume que siempre existe una ruta de liquidez válida para el swap.
* **Escenario de Ataque:** Un usuario intenta depositar un token cuya liquidez en Uniswap ha sido retirada o es inexistente.
* **Impacto:** **BAJO**. La transacción revierte con `NoLiquidityPath`, causando pérdida de gas y una mala experiencia de usuario (UX), aunque los fondos permanecen seguros.

---

## 4. Especificación de Invariantes

Estas son las "reglas de oro" que el sistema debe cumplir en todo momento (Invariant Breaks):

1.  **Invariante de Solvencia:**
    El contrato debe tener suficientes USDC físicos para cubrir la deuda total registrada.
    > `IERC20(usdc).balanceOf(address(this)) >= totalValueLockedUSD`

2.  **Invariante de Consistencia Contable:**
    La suma de los saldos individuales de todos los usuarios debe ser idéntica al total global rastreado.
    > `∑ (vaults[user]) == totalValueLockedUSD`

3.  **Invariante de Límite Bancario (Bank Cap):**
    El valor total bloqueado nunca debe exceder la capacidad máxima configurada por el admin.
    > `totalValueLockedUSD <= bankCapUSD`

---

## 5. Impacto de las Violaciones de Invariantes

* **Si falla la Solvencia:** El protocolo es insolvente. Los últimos usuarios en intentar retirar perderán sus fondos (similar a una corrida bancaria).
* **Si falla la Consistencia:** Indica un error lógico en la contabilidad (suma/resta). Podría permitir a un usuario retirar fondos que no le corresponden o destruir valor virtualmente.
* **Si falla el Bank Cap:** El protocolo está expuesto a un riesgo económico mayor al diseñado, fallando en su promesa de seguridad acotada.

---

## 6. Recomendaciones

Para preparar el contrato para una auditoría externa y posterior despliegue:

1.  **Mitigar Riesgo de Admin (Critical):**
    Modificar `emergencyWithdraw` para impedir explícitamente el retiro del token `usdc`.
    ```solidity
    if (token == address(usdc)) revert CannotWithdrawCollateral();
    ```
2.  **Slippage Dinámico (Medium):**
    Permitir que el usuario especifique un `minAmountOut` en la función de depósito para protegerse de la volatilidad sin bloquear el servicio.
3.  **Implementar Invariant Tests:**
    Utilizar herramientas como **Foundry** para escribir tests que verifiquen las fórmulas de la sección 4 de manera automática en miles de escenarios aleatorios.
4.  **Timelock:**
    Añadir un retardo temporal para cambios críticos de configuración (`updateBankCap`), dando tiempo a los usuarios de reaccionar.

---

## 7. Conclusión

El contrato **KipuBankV3** demuestra una arquitectura modular correcta y hace un buen uso de librerías de seguridad estándar (`SafeERC20`, `ReentrancyGuard`). La lógica de integración con Uniswap es funcional.

Sin embargo, el protocolo **NO está listo para Mainnet** debido al riesgo de centralización en la función de retiro de emergencia. Se recomienda corregir este hallazgo crítico y completar una suite de pruebas de integración antes de proceder a una auditoría profesional.