// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CryptoStudentBank
 * @dev Kontrak cerdas untuk simulasi tabungan mahasiswa dengan fitur transfer antar nasabah.
 */
contract CryptoStudentBank {
    // Mapping untuk mencatat saldo setiap alamat dompet mahasiswa
    mapping(address => uint256) public balances;

    // Event untuk dokumentasi log di konsol Remix
    event DepositMade(address indexed account, uint256 amount);
    event WithdrawalMade(address indexed account, uint256 amount);
    event TransferMade(address indexed from, address indexed to, uint256 amount);

    /**
     * @dev Fitur 1: Setor Dana (Deposit)
     */
    function deposit() public payable {
        require(msg.value > 0, "Jumlah deposit harus lebih dari 0");
        balances[msg.sender] += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }

    /**
     * @dev Fitur 2: Tarik Dana (Withdraw)
     */
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Saldo tabungan tidak mencukupi");
        
        balances[msg.sender] -= amount;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Penarikan dana gagal");
        
        emit WithdrawalMade(msg.sender, amount);
    }

    /**
     * @dev Fitur 3: Cek Saldo (Check Balance)
     */
    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @dev TUGAS TAMBAHAN: Fitur Transfer Antar Nasabah
     * @param to Alamat dompet mahasiswa penerima
     * @param amount Jumlah dana yang ditransfer dalam satuan Wei
     */
    function transfer(address to, uint256 amount) public {
        require(to != address(0), "Alamat penerima tidak valid");
        require(balances[msg.sender] >= amount, "Saldo untuk transfer tidak mencukupi");
        
        // Pola Checks-Effects
        balances[msg.sender] -= amount;
        balances[to] += amount;
        
        emit TransferMade(msg.sender, to, amount);
    }
}