# 🖼️ Ajuste Manual com Super Zoom (320x320)

Aplicativo desktop desenvolvido para facilitar o processo de ajuste, reposicionamento e recorte manual de imagens em lote no formato quadrado fixo de **320x320 pixels** com fundo adaptativo branco. Ideal para padronização de fotos, recorte de rostos e preparação de conjuntos de dados (*datasets*).

O projeto conta com **duas versões**:

1. **Versão Python (Multiplataforma):** Desenvolvida com `Tkinter` e `Pillow`, ideal para ambientes de desenvolvimento no Linux, macOS e Windows.
2. **Versão C# Nativa (.NET / Windows Forms):** Criada especificamente para rodar diretamente em **qualquer computador com Windows** sem a necessidade de instalar Python, dependências (`pip`) ou ambiente de desenvolvimento prévio.

---

## ✨ Funcionalidades

* 📁 **Processamento em Lote:** Percorre automaticamente todas as imagens da pasta ou importadas manualmente.
* 🔍 **Super Zoom:** Controle fino de aproximação e afastamento via botões ou rodinha do mouse (*Scroll Wheel*), com ponto focal ancorado no centro da tela.
* ✋ **Arraste Livre:** Movimentação em 2D pelo painel através do clique e arraste com o botão esquerdo do mouse.
* 🟥 **Visualização com Máscara:** Sombreamento periférico semitransparente com moldura vermelha que indica com precisão a área de corte.
* 💾 **Fundo Adaptativo Branco:** Preenche automaticamente o espaço vazio com a cor branca caso a imagem seja menor que 320x320 ou fique descentralizada.
* 📂 **Formatos Suportados:** `.jpg`, `.jpeg`, `.png`, `.tiff`, `.tif`, `.bmp`, `.webp`.

---

## 💻 Versão C# Nativa (Windows - Sem Instalações)

A versão em C# foi projetada para eliminar barreiras de ambiente: o Windows (10 e 11) já inclui de fábrica o compilador nativo do `.NET Framework` (`csc.exe`). Com isso, a aplicação funciona em máquinas corporativas, educacionais ou de terceiros onde o usuário não possui permissão de administrador ou não tem o interpretador Python instalado.

### Como Executar a Versão C#

1. Salve o código híbrido em um arquivo com o nome **`Executar.bat`** (ou qualquer outro nome com extensão `.bat`).
2. Dê um **duplo clique no arquivo `.bat**`.
3. O script detecta o compilador nativo do Windows, gera o executável `AplicativoRecorte.exe` em segundo plano e abre a interface gráfica imediatamente.

### Vantagens da Versão C#

* **Zero Dependências:** Não requer instalação de Python, pacotes `pip`, Java ou SDKs.
* **Alta Performance:** Execução direta no subsistema gráfico do Windows (`GDI+` / `Double Buffering`), sem oscilações de tela (*flickering*).
* **Portabilidade Imediata:** Um único arquivo `.bat` pronto para uso em qualquer PC com Windows.

---

## 🐍 Versão Python (Multiplataforma)

Indicada para quem já possui ambiente Python configurado ou utiliza distribuições Linux e macOS.

### Pré-requisitos

* **Python 3.x**
* Biblioteca **Pillow**

Instale a dependência necessária:

```bash
pip install Pillow

```

### Como Executar a Versão Python

1. Coloque o script Python (`app.py`) na pasta desejada.
2. Adicione as imagens na mesma pasta do script ou selecione-as via interface.
3. Execute o script no terminal:

```bash
python app.py

```

---

## 🎮 Controles e Atalhos

| Ação | Comando |
| --- | --- |
| **Mover a Imagem** | Clique e arraste com o **Botão Esquerdo** do mouse |
| **Aumentar Zoom** | Gire o **Scroll do mouse para cima** ou clique em `➕ Zoom In` |
| **Diminuir Zoom** | Gire o **Scroll do mouse para baixo** ou clique em `➖ Zoom Out` |
| **Salvar o Corte** | Clique no botão verde **Salvar Corte** |
| **Ignorar Imagem** | Clique no botão vermelho **Pular Imagem** |
| **Abrir Imagens/Pastas** | Clique em **📁 Abrir Imagens / Pasta** (versão C#) |

---

## 📁 Estrutura de Pastas

Ao salvar os cortes, o aplicativo cria automaticamente a pasta de saída `rostos_recortados/` no diretório das imagens:

```text
📂 Minha_Pasta/
├── 📄 Executar.bat (ou app.py)
├── 🖼️ foto1.jpg
├── 🖼️ foto2.png
└── 📂 rostos_recortados/            <-- Criada automaticamente
    ├── 🖼️ foto1.jpg                <-- Recorte finalizado (320x320)
    └── 🖼️ foto2.png                <-- Recorte finalizado (320x320)

```
