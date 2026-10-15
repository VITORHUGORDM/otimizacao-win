# Pacote de Otimização do Windows & Drivers de Vídeo

Este pacote foi totalmente atualizado e limpo, removendo qualquer vínculo, branding ou download de servidores de terceiros . Todos os componentes agora são baixados diretamente de fontes oficiais e seguras (Microsoft, NVIDIA, AMD, Intel, Wagnardsoft, 7-Zip, Brave e Orbmu2k).

---

## 📁 Arquivos Incluídos

1. **`1_Otimizar_Windows.ps1`**: 
   - Otimização geral do sistema operacional e debloat.
   - Instalação oficial do 7-Zip, Visual C++ All-in-One (2005 a 2022), DirectX e Brave Browser.
   - Configuração do DDU oficial e preparação para reinicialização em Modo Seguro.
   
2. **`2_Instalar_Drivers_GPU.ps1`**:
   - Menu interativo para instalação limpa dos drivers oficiais da sua placa (NVIDIA, AMD ou Intel).
   - Instalação do Painel de Controle e Nvidia Profile Inspector oficial (Orbmu2k).
   - Importação de perfil de baixíssima latência (input lag reduzido).
   - Ativação do modo MSI (Message Signaled Interrupts) em todas as GPUs.

3. **Arquivos de Suporte (Etapas do Processo)**:
   - `stepone.ps1`: Executado automaticamente em Modo Seguro (ajustes do Defender e limpeza de drivers com DDU).
   - `steptwo.ps1`: Executado automaticamente no boot seguinte (remoção do Edge, ajustes finos do Windows, serviço de Timer Resolution).
   - `reg.reg`, `settimerresolutionservice.cs`, `start2.txt`: Componentes locais utilizados pelo processo.

---

## 🚀 Como Executar

Abra o **PowerShell como Administrador** e execute:

### Passo 1: Otimização do Sistema
```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\Desktop\Otimizacao\1_Otimizar_Windows.ps1"
```
> *Nota: O computador reiniciará automaticamente em Modo Seguro para limpar os drivers antigos e, em seguida, reiniciará novamente para aplicar as otimizações do sistema.*

### Passo 2: Instalação e Ajustes do Driver de Vídeo
Após o retorno definitivo ao Windows:
```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\Desktop\Otimizacao\2_Instalar_Drivers_GPU.ps1"
```
> *Selecione sua fabricante (1 para NVIDIA, 2 para AMD, 3 para Intel) e aguarde a conclusão.*
