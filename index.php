<?php
// VERCEL-OPTIMIZED SERVER
// Работает на Vercel без файловой БД

// НАСТРОЙКИ
$TELEGRAM_BOT_TOKEN = "8259630875:AAEnTMphfLc-Ywoc8H1nJa0dELRBUv9n6p0";
$ADMIN_CHAT_ID = "7922475024";
$SCRIPT_FILE = "secure_final.lua"; // Путь к вашему скрипту

// Для Vercel используем Telegram как БД
$DB_FILE = null;

// Загрузка БД
function loadDB() {
    global $DB_FILE;
    if (!file_exists($DB_FILE)) {
        return [];
    }
    return json_decode(file_get_contents($DB_FILE), true) ?: [];
}

// Сохранение БД
function saveDB($data) {
    global $DB_FILE;
    file_put_contents($DB_FILE, json_encode($data, JSON_PRETTY_PRINT));
}

// Отправка в Telegram
function sendTelegram($message) {
    global $TELEGRAM_BOT_TOKEN, $ADMIN_CHAT_ID;
    
    $url = "https://api.telegram.org/bot{$TELEGRAM_BOT_TOKEN}/sendMessage";
    $data = [
        'chat_id' => $ADMIN_CHAT_ID,
        'text' => $message,
        'parse_mode' => 'HTML'
    ];
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_exec($ch);
    curl_close($ch);
}

// API: Авторизация
if ($_GET['action'] == 'auth') {
    $deviceId = $_GET['id'] ?? '';
    $version = $_GET['v'] ?? '';
    
    if (empty($deviceId)) {
        die("ERROR");
    }
    
    $db = loadDB();
    
    // Проверяем статус устройства
    if (isset($db[$deviceId])) {
        $device = $db[$deviceId];
        
        if ($device['status'] == 'approved') {
            // Обновляем последний вход
            $db[$deviceId]['last_seen'] = date('Y-m-d H:i:s');
            $db[$deviceId]['launches']++;
            saveDB($db);
            
            echo "APPROVED";
            exit;
        } elseif ($device['status'] == 'denied') {
            echo "DENIED";
            exit;
        } else {
            echo "PENDING";
            exit;
        }
    }
    
    // Новое устройство - создаем запрос
    $db[$deviceId] = [
        'status' => 'pending',
        'created' => date('Y-m-d H:i:s'),
        'last_seen' => date('Y-m-d H:i:s'),
        'version' => $version,
        'launches' => 0
    ];
    saveDB($db);
    
    // Отправляем уведомление админу
    $message = "🔐 <b>NEW DEVICE</b>\n\n" .
               "ID: <code>{$deviceId}</code>\n" .
               "Version: {$version}\n" .
               "Time: " . date('Y-m-d H:i:s') . "\n\n" .
               "━━━━━━━━━━━━━━━━━━━━\n" .
               "Approve: <code>/approve {$deviceId}</code>\n" .
               "Deny: <code>/deny {$deviceId}</code>";
    
    sendTelegram($message);
    
    echo "PENDING";
    exit;
}

// API: Загрузка скрипта
if ($_GET['action'] == 'script') {
    $deviceId = $_GET['id'] ?? '';
    
    if (empty($deviceId)) {
        die("ERROR");
    }
    
    $db = loadDB();
    
    // Проверяем что устройство одобрено
    if (!isset($db[$deviceId]) || $db[$deviceId]['status'] != 'approved') {
        die("DENIED");
    }
    
    // Отдаем скрипт
    if (file_exists($SCRIPT_FILE)) {
        header('Content-Type: text/plain');
        readfile($SCRIPT_FILE);
    } else {
        die("SCRIPT_NOT_FOUND");
    }
    exit;
}

// Webhook для Telegram команд
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $update = json_decode(file_get_contents('php://input'), true);
    
    if (isset($update['message']['text'])) {
        $text = $update['message']['text'];
        
        // Команда /approve
        if (preg_match('/\/approve\s+(\d+)/', $text, $matches)) {
            $deviceId = $matches[1];
            $db = loadDB();
            
            if (isset($db[$deviceId])) {
                $db[$deviceId]['status'] = 'approved';
                $db[$deviceId]['approved_at'] = date('Y-m-d H:i:s');
                saveDB($db);
                
                sendTelegram("✅ Device approved: <code>{$deviceId}</code>");
            }
        }
        
        // Команда /deny
        if (preg_match('/\/deny\s+(\d+)/', $text, $matches)) {
            $deviceId = $matches[1];
            $db = loadDB();
            
            if (isset($db[$deviceId])) {
                $db[$deviceId]['status'] = 'denied';
                $db[$deviceId]['denied_at'] = date('Y-m-d H:i:s');
                saveDB($db);
                
                sendTelegram("❌ Device denied: <code>{$deviceId}</code>");
            }
        }
        
        // Команда /list
        if ($text == '/list') {
            $db = loadDB();
            $message = "📋 <b>DEVICES LIST</b>\n\n";
            
            foreach ($db as $id => $device) {
                $status = $device['status'] == 'approved' ? '✅' : 
                         ($device['status'] == 'denied' ? '❌' : '⏳');
                $message .= "{$status} <code>{$id}</code>\n";
                $message .= "   Launches: {$device['launches']}\n";
                $message .= "   Last: {$device['last_seen']}\n\n";
            }
            
            sendTelegram($message);
        }
    }
    
    exit;
}

// Главная страница
?>
<!DOCTYPE html>
<html>
<head>
    <title>Loader Server</title>
    <style>
        body { font-family: Arial; max-width: 800px; margin: 50px auto; padding: 20px; }
        .device { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .approved { border-left: 4px solid #4CAF50; }
        .denied { border-left: 4px solid #f44336; }
        .pending { border-left: 4px solid #FF9800; }
    </style>
</head>
<body>
    <h1>🔒 Loader Server</h1>
    <p>Server is running!</p>
    
    <h2>Devices:</h2>
    <?php
    $db = loadDB();
    foreach ($db as $id => $device) {
        $class = $device['status'];
        echo "<div class='device {$class}'>";
        echo "<strong>ID:</strong> {$id}<br>";
        echo "<strong>Status:</strong> {$device['status']}<br>";
        echo "<strong>Launches:</strong> {$device['launches']}<br>";
        echo "<strong>Last Seen:</strong> {$device['last_seen']}<br>";
        echo "</div>";
    }
    ?>
    
    <h2>API Endpoints:</h2>
    <ul>
        <li><code>/api?action=auth&id=DEVICE_ID&v=VERSION</code> - Authorization</li>
        <li><code>/api?action=script&id=DEVICE_ID</code> - Get Script</li>
    </ul>
    
    <h2>Telegram Commands:</h2>
    <ul>
        <li><code>/approve DEVICE_ID</code> - Approve device</li>
        <li><code>/deny DEVICE_ID</code> - Deny device</li>
        <li><code>/list</code> - List all devices</li>
    </ul>
</body>
</html>
