// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TuitionPayment
 * @dev Kontrak aman untuk simulasi pembayaran SPP mahasiswa secara digital.
 */
contract TuitionPayment {
    // Mapping untuk mencatat saldo deposit mahasiswa
    mapping(address => uint256) public studentBalances;
    
    // Alamat admin (bagian keuangan kampus)
    address public admin;
    
    // Status darurat untuk mengunci penarikan jika terjadi serangan/bug
    bool public isPaused;

    // Events untuk pencatatan log transaksi di konsol Remix
    event DepositMade(address indexed student, uint256 amount);
    event WithdrawalMade(address indexed student, uint256 amount);
    event EmergencyStatusChanged(bool paused);

    // Modifier untuk membatasi akses hanya untuk Admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Akses ditolak: Hanya untuk Admin Keuangan");
        _;
    }

    // Modifier untuk menghentikan fungsi saat kondisi darurat active
    modifier whenNotPaused() {
        require(!isPaused, "Kontrak sedang ditangguhkan dalam kondisi darurat");
        _;
    }

    constructor() {
        admin = msg.sender;
        isPaused = false;
    }

    /**
     * @dev Mahasiswa menyetor dana ke akun pendidikan mereka.
     */
    function depositTuition() public payable whenNotPaused {
        require(msg.value > 0, "Jumlah deposit harus lebih dari 0");
        studentBalances[msg.sender] += msg.value;
        
        emit DepositMade(msg.sender, msg.value);
    }

    /**
     * @dev Mahasiswa menarik kembali dana jika ada kelebihan bayar.
     * Menggunakan pola Checks-Effects-Interactions & metode .call() yang aman.
     */
    function withdrawOverpayment(uint256 _amount) public whenNotPaused {
        // 1. Checks
        require(studentBalances[msg.sender] >= _amount, "Saldo tidak mencukupi");
        
        // 2. Effects
        studentBalances[msg.sender] -= _amount;
        
        // 3. Interactions (.call menggantikan .transfer untuk menghilangkan warning)
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Transfer dana gagal");

        emit WithdrawalMade(msg.sender, _amount);
    }

    /**
     * @dev Mengecek saldo dana pendidikan milik pengirim.
     */
    function getMyBalance() public view returns (uint256) {
        return studentBalances[msg.sender];
    }

    /**
     * @dev FUNGSI ADMIN: Mengunci atau membuka kembali aktivitas kontrak (Circuit Breaker).
     */
    function toggleEmergencyPause() public onlyAdmin {
        isPaused = !isPaused;
        emit EmergencyStatusChanged(isPaused);
    }

    /**
     * @dev FUNGSI ADMIN: Mengambil dana tersisa di dalam kontrak jika terjadi salah transfer darurat.
     */
    function emergencyWithdraw(uint256 _amount) public onlyAdmin {
        require(address(this).balance >= _amount, "Saldo kontrak tidak mencukupi");
        (bool success, ) = payable(admin).call{value: _amount}("");
        require(success, "Penarikan darurat gagal");
    }
}