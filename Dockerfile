# === Dockerfile for EISeg Application ===

# Step 1: Base Image
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables for non-interactive package installation.
ARG DEBIAN_FRONTEND=noninteractive



# Step 2: Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    git wget sudo \
    # GUI dependencies for PyQt/PySide and X11 forwarding
    libgl1-mesa-glx \
    libglib2.0-0 \
    # FIXED: Add the full set of libraries required for the XCB plugin.
    libx11-xcb1 libxcb-glx0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-xinerama0 libxkbcommon-x11-0 \
    libfontconfig1 \
    libfreetype6 \
    libxcb-shape0 \
    libdbus-1-3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 3: Configure environment for GUI
ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1

# Set the main working directory inside the container.
WORKDIR /app

# Step 4: Install Python dependencies
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

COPY EISeg/requirements.txt ./EISeg/
RUN python3 -m pip install --no-cache-dir -r ./EISeg/requirements.txt

# Install the version of PaddlePaddle you tested.
RUN python3 -m pip install --no-cache-dir paddlepaddle-gpu==2.6.2.post120 -i https://www.paddlepaddle.org.cn/packages/stable/cu120/

# Step 5: Copy application code
COPY . .

# Правки локалей
# RUN apt-get update && apt-get install -y --no-install-recommends locales \
#     && sed -i -E 's/^(#\s*)?en_US\.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
#     && locale-gen en_US.UTF-8 \
#     && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
# ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en

# Step 6: Create user
RUN useradd -ms /bin/bash eiseguser
RUN chown -R eiseguser:eiseguser /app
USER eiseguser



# Step 7: Final configuration and launch
WORKDIR /app/EISeg
CMD ["python3", "-m", "eiseg"]