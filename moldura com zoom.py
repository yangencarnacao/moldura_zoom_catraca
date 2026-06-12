import os
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk, ImageOps

class AplicativoRecorteZoomAmpliado:
    def __init__(self, root):
        self.root = root
        self.root.title("Ajuste Manual com Super Zoom - 320x320")
        
        # Configurações de tamanho do corte alvo
        self.tamanho_alvo = 320
        
        # Caminhos de pastas
        self.pasta_atual = os.path.dirname(os.path.abspath(__file__))
        self.pasta_saida = os.path.join(self.pasta_atual, "rostos_recortados")
        os.makedirs(self.pasta_saida, exist_ok=True)
        
        # Buscar imagens suportadas
        formatos = ('.jpg', '.jpeg', '.png', '.tiff', '.tif', '.bmp', '.webp')
        self.arquivos = [f for f in os.listdir(self.pasta_atual) if f.lower().endswith(formatos)]
        self.indice_atual = 0
        
        if not self.arquivos:
            messagebox.showwarning("Aviso", "Nenhuma imagem encontrada na pasta do script!")
            self.root.destroy()
            return

        # Variáveis de controle de imagem e visualização
        self.img_master = None       # Guarda a imagem original intacta
        self.img_modificada = None   # Imagem após aplicar o zoom atual
        self.zoom_fator = 1.0        # Multiplicador de escala
        
        self.img_x = 0               # Posição X atual da imagem no Canvas
        self.img_y = 0               # Posição Y atual da imagem no Canvas
        self.start_x = 0             # Controle de clique para arrastar
        self.start_y = 0
        
        # Interface - Topo (Informações e Instruções)
        self.label_info = tk.Label(root, text="", font=("Arial", 11, "bold"), pady=5)
        self.label_info.pack()
        
        instrucoes = "Arraste com o botão esquerdo | Use a rodinha do mouse ou os botões para Zoom (Zoom Out ampliado)"
        self.label_instrucao = tk.Label(root, text=instrucoes, font=("Arial", 9), fg="#555555")
        self.label_instrucao.pack()

        # Canvas de Visualização
        self.canvas_largura = 650
        self.canvas_altura = 650
        self.canvas = tk.Canvas(root, width=self.canvas_largura, height=self.canvas_altura, bg="#d0d0d0")
        self.canvas.pack(pady=5)
        
        # Painel de Controles de Zoom
        self.frame_zoom = tk.Frame(root)
        self.frame_zoom.pack(pady=2)
        
        self.btn_zoom_out = tk.Button(self.frame_zoom, text=" ➖ Zoom Out ", command=lambda: self.aplicar_zoom(0.8)) # Aumentado o passo de redução
        self.btn_zoom_out.grid(row=0, column=0, padx=5)
        
        self.btn_zoom_in = tk.Button(self.frame_zoom, text=" ➕ Zoom In ", command=lambda: self.aplicar_zoom(1.2))  # Aumentado o passo de ampliação
        self.btn_zoom_in.grid(row=0, column=1, padx=5)
        
        # Painel de Ações do Script
        self.frame_botoes = tk.Frame(root)
        self.frame_botoes.pack(pady=10)
        
        self.btn_pular = tk.Button(self.frame_botoes, text="Pular Imagem", command=self.proxima_imagem, width=15, bg="#f44336", fg="white")
        self.btn_pular.grid(row=0, column=0, padx=15)
        
        self.btn_salvar = tk.Button(self.frame_botoes, text="Salvar Corte", command=self.salvar_corte, width=15, bg="#4CAF50", fg="white", font=("Arial", 10, "bold"))
        self.btn_salvar.grid(row=0, column=1, padx=15)

        # Eventos do Mouse
        self.canvas.bind("<ButtonPress-1>", self.iniciar_arrasto)
        self.canvas.bind("<B1-Motion>", self.arrastar_imagem)
        
        # Suporte a Scroll do Mouse
        self.canvas.bind("<MouseWheel>", self.evento_scroll_windows)
        self.canvas.bind("<Button-4>", self.evento_scroll_linux_up)
        self.canvas.bind("<Button-5>", self.evento_scroll_linux_down)
        
        self.carregar_imagem_atual()

    def carregar_imagem_atual(self):
        if self.indice_atual >= len(self.arquivos):
            messagebox.showinfo("Fim", "Todas as imagens foram processadas com sucesso!")
            self.root.destroy()
            return
            
        nome_arq = self.arquivos[self.indice_atual]
        self.label_info.config(text=f"Processando ({self.indice_atual + 1}/{len(self.arquivos)}): {nome_arq}")
        
        caminho_img = os.path.join(self.pasta_atual, nome_arq)
        self.img_master = Image.open(caminho_img)
        
        # Define o tamanho inicial padrão centralizado
        largura, altura = self.img_master.size
        self.zoom_fator = 1.0
        self.img_modificada = self.img_master.copy()
        
        self.img_x = (self.canvas_largura - largura) // 2
        self.img_y = (self.canvas_altura - altura) // 2
        
        self.atualizar_canvas()

    def atualizar_canvas(self):
        self.canvas.delete("all")
        
        # Renderiza a imagem na tela
        self.tk_img = ImageTk.PhotoImage(self.img_modificada)
        self.canvas.create_image(self.img_x, self.img_y, anchor="nw", image=self.tk_img)
        
        # Coordenadas do quadro central fixo (320x320)
        x0 = (self.canvas_largura - self.tamanho_alvo) // 2
        y0 = (self.canvas_altura - self.tamanho_alvo) // 2
        x1 = x0 + self.tamanho_alvo
        y1 = y0 + self.tamanho_alvo
        
        # Máscaras de sombreamento
        self.canvas.create_rectangle(0, 0, self.canvas_largura, y0, fill="black", stipple="gray50", width=0)
        self.canvas.create_rectangle(0, y1, self.canvas_largura, self.canvas_altura, fill="black", stipple="gray50", width=0)
        self.canvas.create_rectangle(0, y0, x0, y1, fill="black", stipple="gray50", width=0)
        self.canvas.create_rectangle(x1, y0, self.canvas_largura, y1, fill="black", stipple="gray50", width=0)
        
        # Borda vermelha indicando o limite de 320x320
        self.canvas.create_rectangle(x0, y0, x1, y1, outline="red", width=2)

    def iniciar_arrasto(self, event):
        self.start_x = event.x
        self.start_y = event.y

    def arrastar_imagem(self, event):
        dx = event.x - self.start_x
        dy = event.y - self.start_y
        self.img_x += dx
        self.img_y += dy
        self.start_x = event.x
        self.start_y = event.y
        self.atualizar_canvas()

    def evento_scroll_windows(self, event):
        fator = 1.15 if event.delta > 0 else 0.85
        self.aplicar_zoom(fator)

    def evento_scroll_linux_up(self, event):
        self.aplicar_zoom(1.15)

    def evento_scroll_linux_down(self, event):
        self.aplicar_zoom(0.85)

    def aplicar_zoom(self, multiplicador):
        novo_fator = self.zoom_fator * multiplicador
        
        # Nova trava de segurança: Impede que a imagem fique menor que 50px (Zoom Out quase ilimitado)
        larg_original, alt_original = self.img_master.size
        nova_larg = int(larg_original * novo_fator)
        nova_alt = int(alt_original * novo_fator)
        
        if nova_larg < 50 or nova_alt < 50:
            return
            
        centro_canvas_x = self.canvas_largura / 2
        centro_canvas_y = self.canvas_altura / 2
        
        self.img_x = int(centro_canvas_x - (centro_canvas_x - self.img_x) * multiplicador)
        self.img_y = int(centro_canvas_y - (centro_canvas_y - self.img_y) * multiplicador)
        
        self.zoom_fator = novo_fator
        self.img_modificada = self.img_master.resize((nova_larg, nova_alt), Image.Resampling.LANCZOS)
        self.atualizar_canvas()

    def salvar_corte(self):
        x0_quadro = (self.canvas_largura - self.tamanho_alvo) // 2
        y0_quadro = (self.canvas_altura - self.tamanho_alvo) // 2
        
        # Cria uma imagem em branco (fundo) de 320x320
        corte_final = Image.new("RGB", (self.tamanho_alvo, self.tamanho_alvo), (255, 255, 255))
        
        # Calcula a posição onde a imagem modificada deve ser colada dentro do bloco de 320x320
        pos_relativa_x = self.img_x - x0_quadro
        pos_relativa_y = self.img_y - y0_quadro
        
        # Cola a imagem modificada por cima do fundo branco usando a posição calculada
        corte_final.paste(self.img_modificada, (pos_relativa_x, pos_relativa_y))
        
        # Salva mantendo o mesmo nome original do arquivo
        nome_arq = self.arquivos[self.indice_atual]
        caminho_saida = os.path.join(self.pasta_saida, nome_arq)
        
        corte_final.save(caminho_saida)
        print(f"Salvo perfeitamente com fundo adaptativo: {nome_arq}")
        
        self.proxima_imagem()

    def proxima_imagem(self):
        self.indice_atual += 1
        self.carregar_imagem_atual()

if __name__ == "__main__":
    root = tk.Tk()
    app = AplicativoRecorteZoomAmpliado(root)
    root.mainloop()