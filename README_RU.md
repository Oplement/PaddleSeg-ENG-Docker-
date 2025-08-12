# EISeg (PaddleSeg) — Docker/WSL2 (Windows 11)

Этот репозиторий позволяет запускать **EISeg** (Qt5-GUI) из контейнера Docker на Windows 11 через **WSL2/WSLg**.

---

## Быстрый старт

### 1) Клонирование репозитория

```bash
git clone https://github.com/Oplement/PaddleSeg-ENG-Docker-.git
cd PaddleSeg-ENG-Docker-
```

### 2) Сборка контейнера

```bash
docker build -t eiseg-app .
```

### 3) Запуск контейнера (из терминала WSL)

```bash
docker run -it --rm --gpus all \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  eiseg-app
```

> Рекомендуется запускать **из WSL (Ubuntu)** — так контейнер автоматически получает доступ к графической подсистеме WSLg.

---

## Требования

* Windows 11 c включённым **WSL2**
* Дистрибутив WSL (рекомендуется **Ubuntu 22.04**)
* **Docker Desktop** с бэкендом WSL2
* Драйвер NVIDIA для Windows 11 (WDDM 3.x) с поддержкой WSL2/GPU
* Для GUI: **WSLg** (ставится вместе с `wsl --install`)

---

## Настройка среды (Windows 11 + WSL2 + Docker Desktop)

### 1) Установка и обновление WSL2/WSLg

В **PowerShell от администратора**:

```powershell
wsl --install
wsl --update
wsl --set-default-version 2
wsl --shutdown
```

Установка дистрибутива (например, Ubuntu 22.04) через Microsoft Store или:

```powershell
wsl --install -d Ubuntu-22.04
```

Проверка GUI в WSL (внутри Ubuntu):

```bash
sudo apt update
sudo apt install -y x11-apps
xeyes   # должно открыть окно
```

### 2) Установка и базовая настройка Docker Desktop

* Установите **Docker Desktop for Windows**.
* **Settings → General**: включить **Use the WSL 2 based engine**.
* **Settings → Resources → WSL integration**: включить интеграцию для вашей Ubuntu.
* Перезапустите Docker Desktop.

Проверка доступа к GPU:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

### 3) Драйвер NVIDIA (обязательно)

* Установите/обновите драйвер **NVIDIA** для Windows 11 с поддержкой WSL2.
* После установки перезагрузите ПК.
* Проверка в PowerShell:

```powershell
nvidia-smi
```

### 4) CUDA Toolkit (по необходимости)

**Для запуска контейнера CUDA Toolkit на хосте не требуется.**
Нужен только если планируете собирать CUDA-код **вне контейнера**.

* **Windows (хост):** установщик CUDA Toolkit с сайта NVIDIA.
* **WSL (опционально):**

  ```bash
  sudo apt update
  sudo apt install -y nvidia-cuda-toolkit
  nvcc --version
  ```

---

## Советы по запуску GUI

* Запускайте `docker run` **из WSL** — переменная `DISPLAY` и сокет X11 уже настроены.
* Если окно не появляется, проверьте в WSL:

  ```bash
  echo $DISPLAY
  ls -l /tmp/.X11-unix
  ```

  Должен существовать сокет `X0`.

При артефактах в Qt можно попробовать:

```bash
docker run -it --rm --gpus all \
  -e DISPLAY=$DISPLAY \
  -e QT_QPA_PLATFORM=xcb -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  eiseg-app
```

### Запуск из PowerShell (если нужно)

В PowerShell WSLg-сокеты доступны по другим путям. Пример:

```powershell
docker run -it --rm --gpus all `
  -v /run/desktop/mnt/host/wslg/.X11-unix:/tmp/.X11-unix `
  -e DISPLAY=:0 `
  eiseg-app
```

---

## Частые проблемы

* **Окно не открывается, контейнер сразу завершается.**
  Обычно нет соединения с X11/WSLg. Запускайте из WSL, проверьте `DISPLAY` и монтирование `/tmp/.X11-unix`.

* **`Illegal instruction (core dumped)` на старом CPU.**
  Причина — бинарники Paddle, собранные с AVX/AVX2/AVX-512. Нужен билд Paddle без этих инструкций либо совместимая версия (если собираете свои образы).

---

## Лицензии и исходники

* Оригинальный проект: [PaddleSeg / EISeg](https://github.com/PaddlePaddle/PaddleSeg)

Используйте в соответствии с лицензиями исходных проектов и NVIDIA CUDA.
