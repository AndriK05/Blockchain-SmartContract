// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleBank
 * @dev Kontrak sederhana untuk simulasi deposit, withdraw, dan cek saldo.
 */
contract SimpleBank {
    // Pemetaan untuk menyimpan saldo setiap alamat dompet
    mapping(address => uint) public balances;

    /**
     * @dev Fungsi untuk menyetor ETH ke dalam kontrak.
     * Kata kunci 'payable' memungkinkan kontrak menerima aset.
     */
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    /**
     * @dev Fungsi untuk menarik dana dari kontrak.
     * @param amount Jumlah dalam satuan wei yang ingin ditarik.
     */
    function withdraw(uint amount) public {
        // Validasi: Pastikan saldo mencukupi sebelum penarikan
        require(balances[msg.sender] >= amount, "Saldo tidak mencukupi");

        // Perbarui saldo terlebih dahulu (Best Practice: Checks-Effects-Interactions)
        balances[msg.sender] -= amount;

        // Kirim dana ke pemanggil fungsi
        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev Fungsi untuk mengecek saldo pengirim saat ini.
     * 'view' menunjukkan fungsi ini tidak mengubah status blockchain.
     */
    function checkBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}