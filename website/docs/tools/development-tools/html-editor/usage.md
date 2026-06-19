---
sidebar_position: 3
---

# Использование

## Быстрый старт

1. Откройте меню **Универсальные инструменты → Редактор HTML**.
2. Введите HTML-код в верхней панели.
3. При необходимости добавьте CSS и JavaScript в соответствующие панели.
4. Нажмите **Предпросмотр** или **F5**.
5. Результат отобразится в панели предпросмотра справа.

## Сценарии использования

### Сценарий 1: Создание HTML-шаблона письма

```html
<!DOCTYPE html>
<html>
<head>
<style>
  body { font-family: Arial, sans-serif; }
  .header { background: #2c3e50; color: white; padding: 20px; }
  .content { padding: 20px; }
  .footer { font-size: 12px; color: #999; }
</style>
</head>
<body>
  <div class="header">
    <h1>Уведомление об оплате</h1>
  </div>
  <div class="content">
    <p>Уважаемый клиент, оплата получена.</p>
    <p>Сумма: <strong>15 000 руб.</strong></p>
  </div>
  <div class="footer">
    <p>С уважением, Бухгалтерия</p>
  </div>
</body>
</html>
```

### Сценарий 2: Отладка JavaScript-скрипта

```html
<!DOCTYPE html>
<html>
<body>
  <input type="text" id="name" placeholder="Введите имя">
  <button onclick="greet()">Приветствовать</button>
  <p id="result"></p>

  <script>
    function greet() {
      var name = document.getElementById('name').value;
      document.getElementById('result').textContent =
        'Привет, ' + name + '!';
    }
  </script>
</body>
</html>
```

### Сценарий 3: Тестирование печатной формы

Используйте редактор для отладки макета HTML-печатной формы перед интеграцией в конфигурацию 1С. После отладки скопируйте код для использования с `HTMLПисатель` в BSL.
