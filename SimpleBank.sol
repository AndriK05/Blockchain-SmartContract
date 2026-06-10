// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleBank
 * @dev Kontrak cerdas sederhana untuk simulasi tabungan digital mahasiswa.
 */
contract SimpleBank {
    // Mapping untuk mencatat saldo setiap alamat dompet nasabah
    mapping(address => uint256) public balances;

    /**
     * @dev Fungsi untuk menyetor dana (ETH) ke dalam kontrak.
     */
    function deposit() public payable {
        require(msg.value > 0, "Jumlah deposit harus lebih dari 0");
        balances[msg.sender] += msg.value;
    }

    /**
     * @dev Fungsi untuk menarik dana dari kontrak berdasarkan jumlah (amount) dalam Wei.
     * @param amount Jumlah dana yang ingin ditarik.
     */
    function withdraw(uint256 amount) public {
        // 1. Validasi (Checks): Pastikan saldo di dalam kontrak mencukupi
        require(balances[msg.sender] >= amount, "Saldo tidak mencukupi");

        // 2. Efek internal (Effects): Kurangi saldo catatan sebelum mengirim dana (mencegah re-entrancy)
        balances[msg.sender] -= amount;

        // 3. Interaksi eksternal (Interactions): Kirim dana menggunakan metode .call() yang aman
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer dana gagal");
    }

    /**
     * @dev Fungsi untuk mengecek saldo pengirim saat ini.
     */
    function checkBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}