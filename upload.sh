echo "This tool wipes the device and uploads all lua scripts under the current directory"
echo "Wiping..."
sudo python luatool.py --wipe
for f in *.lua
do

    if [ $f != "init.lua" ]; then
        echo "Uploading: $f"
        sudo python luatool.py --src "$f" --compile
    fi
done
sudo python luatool.py --src "init.lua" --restart --echo
