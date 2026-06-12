# 🖼️ Ajuste Manual com Super Zoom (320x320)

Este é um script em Python que utiliza uma interface gráfica (**Tkinter**) para facilitar o processo de recortar e centralizar imagens manualmente em um formato quadrado fixo de **320x320 pixels**. Ele é ideal para preparar conjuntos de dados (*datasets*), recortar rostos ou padronizar fotos de produtos.

---

## ✨ Funcionalidades

* 📁 **Processamento em lote:** Lê automaticamente todas as imagens suportadas na pasta do script.
* 🔍 **Super Zoom:** Controle total de ampliação e redução via botões ou roda do mouse (*Scroll*).
* ✋ **Arraste Livre:** Mova a imagem livremente pelo painel para focar exatamente no ponto que deseja recortar.
* 🟥 **Visualização em Tempo Real:** Uma guia com borda vermelha e sombreamento ao redor mostra exatamente o que será salvo.
* 💾 **Fundo Adaptativo:** Caso a imagem seja menor que o quadro de 320x320, o script preenche o espaço vazio com um fundo branco limpo.
* 🔄 **Suporte Multiplataforma:** Atalhos configurados para funcionamento correto do Scroll do mouse em **Windows** e **Linux**.

---

## 🚀 Pré-requisitos

Antes de executar o script, você precisará ter o Python instalado e a biblioteca **Pillow** (responsável pelo processamento de imagem).

Instale a biblioteca necessária executando o comando abaixo no seu terminal:

```bash
pip install Pillow

```

*Nota: O `tkinter` e o `os` já vêm instalados por padrão junto com o Python.*

---

## 🛠️ Como Usar

1. Coloque este script em uma pasta no seu computador.
2. Adicione todas as imagens que deseja recortar **na mesma pasta** do script.
* *Formatos suportados: `.jpg`, `.jpeg`, `.png`, `.tiff`, `.tif`, `.bmp`, `.webp*`


3. Execute o script:
```bash
python nome_do_seu_script.py

```


4. Use a interface para ajustar a imagem conforme as instruções de controle abaixo.
5. Clique em **Salvar Corte** para ir para a próxima imagem. As imagens recortadas serão salvas automaticamente em uma nova pasta chamada `rostos_recortados`.

---

## 🎮 Controles e Atalhos

| Ação | Comando |
| --- | --- |
| **Mover a Imagem** | Clique e arraste com o **Botão Esquerdo** do mouse. |
| **Aumentar Zoom** | Gire o **Scroll do mouse para cima** ou clique no botão `➕ Zoom In`. |
| **Diminuir Zoom** | Gire o **Scroll do mouse para baixo** ou clique no botão `➖ Zoom Out`. |
| **Salvar o Corte** | Clique no botão verde `Salvar Corte`. |
| **Ignorar Imagem** | Clique no botão vermelho `Pular Imagem`. |

---

## 📁 Estrutura de Pastas

Após rodar o script e salvar algumas imagens, sua pasta ficará assim:

```text
📂 Minha_Pasta_Do_Script/
├── 📄 seu_script.py
├── 🖼️ foto1.jpg
├── 🖼️ foto2.png
└── 📂 rostos_recortados/           <-- Criada automaticamente
    ├── 🖼️ foto1.jpg                <-- Imagem finalizada (320x320)
    └── 🖼️ foto2.png                <-- Imagem finalizada (320x320)

```
