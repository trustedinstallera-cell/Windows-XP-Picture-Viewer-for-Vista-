#include <windows.h>
#include <string>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    LPSTR lpCmdLine, int nCmdShow) {
    char exeFullPath[MAX_PATH];
    GetModuleFileNameA(NULL, exeFullPath, MAX_PATH);

    std::string path(exeFullPath);
    size_t lastSlash = path.find_last_of("\\/");
    std::string folder = path.substr(0, lastSlash + 1);

    std::string param1 = lpCmdLine;
    size_t start = param1.find_first_not_of(" \t");
    if (start != std::string::npos) {
        param1 = param1.substr(start);
        if (param1[0] == '"') {
            size_t end = param1.find('"', 1);
            if (end != std::string::npos) {
                param1 = param1.substr(1, end - 1);
            }
        }
        else {
            size_t end = param1.find_first_of(" \t");
            if (end != std::string::npos) {
                param1 = param1.substr(0, end);
            }
        }
    }
    else {
        param1 = "";
    }

    std::string cmdLine = folder + "rundll32.exe \"" + folder + "shimgvw.dll\",ImageView_Fullscreen " + param1;
    WinExec(cmdLine.c_str(), SW_HIDE);

    return 0;
}