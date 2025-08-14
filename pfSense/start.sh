#/bin/sh

setup() {
    echo "#################################################"
    echo "$(date)"

    # Create obscure directory to store inventory data
    if [ ! -d /usr/share/vt/fonts/blueteam ]; then
        mkdir -p /usr/share/vt/fonts/blueteam
    fi
}

serve() {
    cd core
    sh inventory.sh
    sh backup.sh
    sh audit.sh
    # sh secure.sh
    # sh logging.sh
}

serve | tee /usr/share/ct/fonts/blueteam/meal.txt
cd ..
