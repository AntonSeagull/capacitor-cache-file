import { cacheFile } from 'capacitor-cache-file';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    cacheFile.echo({ value: inputValue })
}
