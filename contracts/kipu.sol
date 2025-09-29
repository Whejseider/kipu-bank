// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @author Whejseider - Franco Vallone
 * @notice Este contrato es parte del curso ETH KIPU || Módulo 2 - Fundamentos de Solidity
 * @custom:security Este es un contrato educativo y no debe ser usado en producción
 */
contract KipuBank {
    /*///////////////////////////////////
          Type declarations
///////////////////////////////////*/

    ///@notice mapping para almacenar la dirección de un usuario y los fondos.
    mapping(address usuario => uint256 balance) private bovedas;

    ///@notice estructura para almacenar el registro de depósitos y retiros
    struct Registro {
        uint256 numerosDeDepositos;
        uint256 numerosDeRetiros;
    }

    /*///////////////////////////////////
           State variables
///////////////////////////////////*/

    ///@notice variable de estado para registrar los depósitos y retiros
    Registro private registro;

    ///@notice umbral de retiro de fondos de la bóveda
    uint256 private immutable umbralRetiro;

    ///@notice límite global de depósitos
    uint256 private immutable bankCap;

    ///@notice balance total depositado por todos los usuarios
    uint256 private depositosTotales;

    /*///////////////////////////////////
               Events
///////////////////////////////////*/

    ///@notice evento emitido al realizar exitosamente un depósito
    event DepositoExitoso(address depositante, uint256 valor);
    ///@notice evento emitido al realizar exitosamente un retiro
    event RetiroExitoso(address depositario, uint256 valor);

    /*///////////////////////////////////
               Errors
///////////////////////////////////*/

    ///@notice error al intentar retirar más del límite permitido
    error RetiroNoValido(uint256 cantidad, uint256 umbral);

    ///@notice error al intentar retirar más de lo que tiene el usuario
    error SaldoInsuficiente(uint256 balance, uint256 cantidad);

    ///@notice Error si el depósito supera el límite global del banco
    error BankCapExcedido(uint256 cantidad, uint256 bankCap);

    ///@notice error si falla la transferencia de ETH
    error TransferenciaFallida(address destino, uint256 cantidad);

    ///@notice error cuando un valor no puede ser cero ni negativo
    error ValorNoPuedeSerCeroONegativo();

    ///@notice error cuando el que quiere depositar o retirar no es el dueño de la bóveda
    error NoEsOwnerBoveda();

    /*///////////////////////////////////
            Modifiers
///////////////////////////////////*/

    ///@notice verifica que sólo el dueño de la bóveda pueda realizar retiros de fondos
    modifier onlyOwnerBoveda() {
        if (bovedas[msg.sender] == 0) {
            revert NoEsOwnerBoveda();
        }
        _;
    }

    /*///////////////////////////////////
            Functions
///////////////////////////////////*/

    /*/////////////////////////
        constructor
/////////////////////////*/

    constructor(uint256 _bankCap, uint256 _umbralRetiro) {
        bankCap = _bankCap;
        umbralRetiro = _umbralRetiro;
        registro.numerosDeDepositos = 0;
        registro.numerosDeRetiros = 0;
    }

    /*/////////////////////////
     Receive&Fallback
/////////////////////////*/

    ///@notice función para recibir ether directamente
    receive() external payable {}
    fallback() external {}

    /*/////////////////////////
        external
/////////////////////////*/

    /*
		@notice Función utilizada para retirar fondos de una bóveda
		@para cantidad - cantidad de fondos a retirar
	*/
    function retiro(uint256 cantidad) external onlyOwnerBoveda {
        if (cantidad <= 0) revert ValorNoPuedeSerCeroONegativo();
        if (cantidad > bovedas[msg.sender])
            revert SaldoInsuficiente(bovedas[msg.sender], cantidad);
        if (cantidad > umbralRetiro)
            revert RetiroNoValido(cantidad, umbralRetiro);

        bovedas[msg.sender] -= cantidad;
        depositosTotales -= cantidad;
        registro.numerosDeRetiros++;

        _transferirETH(cantidad);

        emit RetiroExitoso(msg.sender, cantidad);
    }

    /*
		@notice Función utilizada para depositar fondos a una bóveda
	*/
    function deposito() external payable {
        if (msg.value <= 0) revert ValorNoPuedeSerCeroONegativo();
        if (msg.value + depositosTotales > bankCap)
            revert BankCapExcedido(msg.value, bankCap);

        bovedas[msg.sender] += msg.value;
        depositosTotales += msg.value;
        registro.numerosDeDepositos++;

        emit DepositoExitoso(msg.sender, msg.value);
    }

    /*/////////////////////////
         public
/////////////////////////*/

    /*/////////////////////////
        internal
/////////////////////////*/

    /*/////////////////////////
        private
/////////////////////////*/

    /*
		@notice Función utilizada para transferir ETH
		@para cantidad - cantidad de fondos a transferir
	*/
    function _transferirETH(uint256 cantidad) private {
        (bool exito, ) = msg.sender.call{value: cantidad}("");
        if (!exito) revert TransferenciaFallida(msg.sender, cantidad);
    }

    /*/////////////////////////
      View & Pure
/////////////////////////*/

    /*
        @notice devuelve el balance o fondo del usuario
        @para usuario - dirección de la address del usuario
    */
    function balanceUsuario(address usuario) public view returns (uint256) {
        return bovedas[usuario];
    }

    /*
        @notice devuelve el valor total de los depósitos
    */
    function verDepositosTotales() public view returns (uint256) {
        return depositosTotales;
    }

    /*
        @notice devuelve el bankCap
    */
    function verBankCap() public view returns (uint256) {
        return bankCap;
    }

    /*
        @notice devuelve registro de los números de depósitos y retiros realizados
    */
    function verRegistros() public view returns (uint256, uint256) {
        return (registro.numerosDeDepositos, registro.numerosDeRetiros);
    }

    /*
        @notice devuelve el umbral de retiro
    */
    function verUmbralDeRetiro() public view returns (uint256) {
        return umbralRetiro;
    }
}
