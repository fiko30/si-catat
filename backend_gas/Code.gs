/**
 * =========================================================================
 * BACKEND GOOGLE APPS SCRIPT (GAS) - SI CATAT (DILENGKAPI AUTO-SETUP)
 * =========================================================================
 */

// JALANKAN FUNGSI INI DI APPS SCRIPT (Klik "Jalankan" / "Run") UNTUK MENGISI HEADER OTOMATIS
function setupDatabase() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // 1. Setup Sheet Users
  var usersSheet = ss.getSheetByName('Users') || ss.insertSheet('Users');
  var userHeaders = [['user_id', 'name', 'email', 'password', 'created_at']];
  usersSheet.getRange(1, 1, 1, 5).setValues(userHeaders);
  usersSheet.getRange(1, 1, 1, 5)
    .setFontWeight('bold')
    .setBackground('#2EAA56')
    .setFontColor('#FFFFFF');
  usersSheet.setFrozenRows(1);

  // 2. Setup Sheet Transactions
  var trxSheet = ss.getSheetByName('Transactions') || ss.insertSheet('Transactions');
  var trxHeaders = [[
    'transaction_id', 'user_id', 'type', 'source', 'amount', 
    'description', 'transaction_date', 'created_at', 'updated_at'
  ]];
  trxSheet.getRange(1, 1, 1, 9).setValues(trxHeaders);
  trxSheet.getRange(1, 1, 1, 9)
    .setFontWeight('bold')
    .setBackground('#2EAA56')
    .setFontColor('#FFFFFF');
  trxSheet.setFrozenRows(1);

  Logger.log('Tabel Users dan Transactions berhasil dibuat dan diformat otomatis!');
}

// JALANKAN FUNGSI INI 1x DI EDITOR APPS SCRIPT (Klik "Jalankan" / "Run") UNTUK MEMBERIKAN IZIN KIRIM EMAIL
function aktivasiIzinEmail() {
  var kuota = MailApp.getRemainingDailyQuota();
  Logger.log('Izin kirim email berhasil aktif! Sisa kuota email harian akun Anda: ' + kuota);
}

function doPost(e) {
  var lock = LockService.getScriptLock();
  try {
    lock.waitLock(10000);
  } catch (err) {
    return createJsonResponse({ status: 'error', message: 'Server sibuk, coba beberapa saat lagi' });
  }

  try {
    var contents = (e && e.postData && e.postData.contents) ? e.postData.contents : '{}';
    var data = JSON.parse(contents);
    var action = data.action;

    var ss = SpreadsheetApp.getActiveSpreadsheet();
    
    // Pastikan tabel siap
    var usersSheet = getOrCreateSheet(ss, 'Users', ['user_id', 'name', 'email', 'password', 'created_at']);
    var trxSheet = getOrCreateSheet(ss, 'Transactions', [
      'transaction_id', 'user_id', 'type', 'source', 'amount', 
      'description', 'transaction_date', 'created_at', 'updated_at'
    ]);

    var result;
    switch (action) {
      case 'setup':
        setupDatabase();
        result = { status: 'success', message: 'Tabel berhasil disiapkan otomatis' };
        break;
      case 'register':
        result = handleRegister(usersSheet, data);
        break;
      case 'login':
        result = handleLogin(usersSheet, data);
        break;
      case 'forgotPassword':
        result = handleForgotPassword(usersSheet, data);
        break;
      case 'getTransactions':
        result = handleGetTransactions(trxSheet, data);
        break;
      case 'addTransaction':
        result = handleAddTransaction(trxSheet, data);
        break;
      case 'editTransaction':
        result = handleEditTransaction(trxSheet, data);
        break;
      case 'deleteTransaction':
        result = handleDeleteTransaction(trxSheet, data);
        break;
      default:
        result = { status: 'error', message: 'Action tidak dikenal: ' + action };
    }

    return createJsonResponse(result);

  } catch (error) {
    return createJsonResponse({ status: 'error', message: 'Terjadi kesalahan server: ' + error.toString() });
  } finally {
    lock.releaseLock();
  }
}

function getOrCreateSheet(ss, sheetName, defaultHeaders) {
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    if (sheets[i].getName().trim().toLowerCase() === sheetName.toLowerCase()) {
      var s = sheets[i];
      // Jika baris 1 kosong, isi header
      if (s.getLastRow() === 0) {
        s.appendRow(defaultHeaders);
        s.getRange(1, 1, 1, defaultHeaders.length).setFontWeight('bold').setBackground('#2EAA56').setFontColor('#FFFFFF');
        s.setFrozenRows(1);
      }
      return s;
    }
  }
  var newSheet = ss.insertSheet(sheetName);
  newSheet.appendRow(defaultHeaders);
  newSheet.getRange(1, 1, 1, defaultHeaders.length).setFontWeight('bold').setBackground('#2EAA56').setFontColor('#FFFFFF');
  newSheet.setFrozenRows(1);
  return newSheet;
}

// 1. REGISTER
function handleRegister(sheet, data) {
  var email = (data.email || '').trim().toLowerCase();
  var name = (data.name || '').trim();
  var password = data.password || '';

  if (!email || !password || !name) {
    return { status: 'error', message: 'Nama, email, dan password wajib diisi' };
  }

  var values = sheet.getDataRange().getValues();
  for (var i = 1; i < values.length; i++) {
    if (values[i][2] && values[i][2].toString().toLowerCase() === email) {
      return { status: 'error', message: 'Email sudah terdaftar. Silakan login.' };
    }
  }

  var userId = 'USR-' + new Date().getTime();
  var createdAt = Utilities.formatDate(new Date(), 'Asia/Jakarta', 'yyyy-MM-dd HH:mm:ss');

  sheet.appendRow([userId, name, email, password, createdAt]);

  return {
    status: 'success',
    message: 'Pendaftaran akun berhasil',
    data: {
      user_id: userId,
      name: name,
      email: email
    }
  };
}

// 2. LOGIN
function handleLogin(sheet, data) {
  var email = (data.email || '').trim().toLowerCase();
  var password = data.password || '';

  var values = sheet.getDataRange().getValues();
  for (var i = 1; i < values.length; i++) {
    var rowEmail = values[i][2] ? values[i][2].toString().toLowerCase() : '';
    var rowPassword = values[i][3] ? values[i][3].toString() : '';

    if (rowEmail === email && rowPassword === password) {
      return {
        status: 'success',
        message: 'Login berhasil',
        data: {
          user_id: values[i][0].toString(),
          name: values[i][1].toString(),
          email: values[i][2].toString()
        }
      };
    }
  }

  return { status: 'error', message: 'Email atau password salah' };
}

// 2B. FORGOT PASSWORD (Kirim Password ke Email Pengguna)
function handleForgotPassword(sheet, data) {
  var email = (data.email || '').trim().toLowerCase();
  if (!email) {
    return { status: 'error', message: 'Email wajib diisi' };
  }

  var values = sheet.getDataRange().getValues();
  for (var i = 1; i < values.length; i++) {
    var rowEmail = values[i][2] ? values[i][2].toString().toLowerCase() : '';
    if (rowEmail === email) {
      var name = values[i][1] ? values[i][1].toString() : 'Pengguna';
      var password = values[i][3] ? values[i][3].toString() : '';

      try {
        MailApp.sendEmail({
          to: email,
          subject: '🔐 Pemulihan Password Akun Si Catat',
          htmlBody: `
            <div style="font-family: Arial, sans-serif; padding: 24px; color: #1E293B; max-width: 500px; border: 1px solid #E2E8F0; border-radius: 16px;">
              <h2 style="color: #2EAA56; margin-top: 0;">Si Catat</h2>
              <p>Halo <b>${name}</b>,</p>
              <p>Kami menerima permintaan pemulihan password untuk akun Anda di aplikasi <b>Si Catat</b>.</p>
              <div style="background-color: #F0FDF4; border-left: 4px solid #2EAA56; padding: 14px 18px; margin: 18px 0; border-radius: 8px;">
                <p style="margin: 0; font-size: 13px; color: #64748B;">Password Akun Anda:</p>
                <h3 style="margin: 6px 0 0 0; color: #1E293B; letter-spacing: 1.5px; font-size: 20px;">${password}</h3>
              </div>
              <p style="font-size: 13px; color: #64748B; line-height: 1.5;">Demi keamanan akun Anda, jangan berikan password ini kepada siapapun. Jika Anda tidak merasa meminta email ini, akun Anda tetap aman dan Anda bisa mengabaikannya.</p>
              <hr style="border: none; border-top: 1px solid #E2E8F0; margin: 20px 0;" />
              <p style="font-size: 12px; color: #94A3B8; margin: 0;">Aplikasi Pengelolaan Uang Si Catat</p>
            </div>
          `
        });

        return {
          status: 'success',
          message: 'Password telah berhasil dikirim ke email Anda! Silakan periksa inbox atau spam.'
        };
      } catch (mailError) {
        return {
          status: 'error',
          message: 'Gagal mengirim email: ' + mailError.toString()
        };
      }
    }
  }

  return { status: 'error', message: 'Email tidak ditemukan di sistem kami' };
}

// 3. GET TRANSACTIONS
function handleGetTransactions(sheet, data) {
  var userId = (data.user_id || '').toString();
  if (!userId) {
    return { status: 'error', message: 'user_id tidak valid' };
  }

  var values = sheet.getDataRange().getValues();
  var transactions = [];

  for (var i = 1; i < values.length; i++) {
    var row = values[i];
    var rowUserId = row[1] ? row[1].toString() : '';

    if (rowUserId === userId) {
      var rawDate = row[6];
      var formattedDate = '';
      if (rawDate instanceof Date) {
        formattedDate = Utilities.formatDate(rawDate, 'Asia/Jakarta', 'yyyy-MM-dd');
      } else {
        formattedDate = rawDate ? rawDate.toString().substring(0, 10) : '';
      }

      transactions.push({
        transaction_id: row[0] ? row[0].toString() : '',
        user_id: row[1] ? row[1].toString() : '',
        type: row[2] ? row[2].toString() : 'pengeluaran',
        source: row[3] ? row[3].toString() : '',
        amount: Number(row[4]) || 0,
        description: row[5] ? row[5].toString() : '',
        transaction_date: formattedDate,
        created_at: row[7] ? row[7].toString() : '',
        updated_at: row[8] ? row[8].toString() : ''
      });
    }
  }

  return {
    status: 'success',
    data: transactions
  };
}

// 4. ADD TRANSACTION
function handleAddTransaction(sheet, data) {
  var userId = (data.user_id || '').toString();
  var type = (data.type || 'pengeluaran').toLowerCase();
  var source = (data.source || '').trim();
  var amount = Number(data.amount) || 0;
  var description = (data.description || '').trim();
  var transactionDate = data.transaction_date || Utilities.formatDate(new Date(), 'Asia/Jakarta', 'yyyy-MM-dd');

  var trxId = 'TRX-' + new Date().getTime();
  var now = Utilities.formatDate(new Date(), 'Asia/Jakarta', 'yyyy-MM-dd HH:mm:ss');

  sheet.appendRow([
    trxId,
    userId,
    type,
    source,
    amount,
    description,
    transactionDate,
    now,
    now
  ]);

  return {
    status: 'success',
    message: 'Transaksi berhasil disimpan',
    data: {
      transaction_id: trxId
    }
  };
}

// 5. EDIT TRANSACTION
function handleEditTransaction(sheet, data) {
  var trxId = (data.transaction_id || '').toString();
  var userId = (data.user_id || '').toString();

  var values = sheet.getDataRange().getValues();
  for (var i = 1; i < values.length; i++) {
    if (values[i][0] && values[i][0].toString() === trxId) {
      var rowIndex = i + 1;
      var now = Utilities.formatDate(new Date(), 'Asia/Jakarta', 'yyyy-MM-dd HH:mm:ss');

      var type = data.type || values[i][2];
      var source = data.source || values[i][3];
      var amount = Number(data.amount) || values[i][4];
      var description = data.description !== undefined ? data.description : values[i][5];
      var transactionDate = data.transaction_date || values[i][6];
      var createdAt = values[i][7];

      sheet.getRange(rowIndex, 1, 1, 9).setValues([[
        trxId,
        userId || values[i][1],
        type,
        source,
        amount,
        description,
        transactionDate,
        createdAt,
        now
      ]]);

      return { status: 'success', message: 'Transaksi berhasil diperbarui' };
    }
  }

  return { status: 'error', message: 'Transaksi tidak ditemukan' };
}

// 6. DELETE TRANSACTION
function handleDeleteTransaction(sheet, data) {
  var trxId = (data.transaction_id || '').toString();

  var values = sheet.getDataRange().getValues();
  for (var i = 1; i < values.length; i++) {
    if (values[i][0] && values[i][0].toString() === trxId) {
      sheet.deleteRow(i + 1);
      return { status: 'success', message: 'Transaksi berhasil dihapus' };
    }
  }

  return { status: 'error', message: 'Transaksi tidak ditemukan' };
}

function createJsonResponse(data) {
  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

function doGet(e) {
  return createJsonResponse({
    status: 'success',
    message: 'Backend Google Apps Script Si Catat aktif dan siap digunakan!'
  });
}
