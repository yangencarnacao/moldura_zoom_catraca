// 2>nul||@goto :batch
/*
:batch
@echo off
setlocal
cd /d "%~dp0"

set "EXE_NAME=AplicativoRecorte.exe"

if exist "%EXE_NAME%" (
    start "" "%EXE_NAME%"
    exit /b
)

set "CSC="
if exist "%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\csc.exe" (
    set "CSC=%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
) else if exist "%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\csc.exe" (
    set "CSC=%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)

if "%CSC%"=="" (
    echo [ERRO] Compilador nativo .NET Framework nao foi encontrado.
    pause
    exit /b
)

"%CSC%" /nologo /target:winexe /out:"%EXE_NAME%" "%~f0"

if exist "%EXE_NAME%" (
    start "" "%EXE_NAME%"
) else (
    echo [ERRO] Falha ao compilar o aplicativo.
    pause
)
exit /b
*/

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace RecorteApp
{
    public class AplicativoRecorteZoomAmpliado : Form
    {
        private readonly int tamanhoAlvo = 320;
        private readonly int canvasLargura = 650;
        private readonly int canvasAltura = 650;

        private string pastaSaida;
        private readonly List<string> arquivos = new List<string>();
        private int indiceAtual = 0;

        private Image imgMaster;
        private double zoomFator = 1.0;
        private int imgX = 0;
        private int imgY = 0;
        private Point startPoint;
        private bool arrastando = false;

        private readonly Label labelInfo;
        private readonly Panel canvasPanel;

        public AplicativoRecorteZoomAmpliado()
        {
            this.Text = "Ajuste Manual com Super Zoom - 320x320";
            this.ClientSize = new Size(670, 790);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;

            string pastaAtual = AppDomain.CurrentDomain.BaseDirectory;
            pastaSaida = Path.Combine(pastaAtual, "rostos_recortados");
            if (!Directory.Exists(pastaSaida))
            {
                Directory.CreateDirectory(pastaSaida);
            }

            Panel painelTopo = new Panel { Dock = DockStyle.Top, Height = 80 };

            labelInfo = new Label
            {
                Text = "Nenhuma imagem carregada",
                Dock = DockStyle.Top,
                Height = 25,
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font("Arial", 10, FontStyle.Bold)
            };

            Label labelInstrucao = new Label
            {
                Text = "Arraste com o botão esquerdo | Use a rodinha do mouse ou os botões para Zoom",
                Dock = DockStyle.Top,
                Height = 20,
                TextAlign = ContentAlignment.MiddleCenter,
                Font = new Font("Arial", 8, FontStyle.Regular),
                ForeColor = Color.FromArgb(90, 90, 90)
            };

            Button btnImportar = new Button
            {
                Text = "📁 Abrir Imagens / Pasta",
                Width = 180,
                Height = 28,
                Location = new Point((670 - 180) / 2, 48),
                Font = new Font("Arial", 9)
            };
            btnImportar.Click += (s, e) => EscolherImagens();

            painelTopo.Controls.Add(btnImportar);
            painelTopo.Controls.Add(labelInstrucao);
            painelTopo.Controls.Add(labelInfo);
            this.Controls.Add(painelTopo);

            canvasPanel = new CanvasDuploBuffer
            {
                Size = new Size(canvasLargura, canvasAltura),
                Location = new Point(10, 85),
                BackColor = Color.FromArgb(208, 208, 208)
            };
            ConfigurarEventosCanvas();
            this.Controls.Add(canvasPanel);

            Panel painelControles = new Panel { Dock = DockStyle.Bottom, Height = 80 };

            Button btnZoomOut = new Button
            {
                Text = " ➖ Zoom Out ",
                Size = new Size(110, 26),
                Location = new Point(215, 6)
            };
            btnZoomOut.Click += (s, e) => AplicarZoom(0.8);

            Button btnZoomIn = new Button
            {
                Text = " ➕ Zoom In ",
                Size = new Size(110, 26),
                Location = new Point(345, 6)
            };
            btnZoomIn.Click += (s, e) => AplicarZoom(1.2);

            Button btnPular = new Button
            {
                Text = "Pular Imagem",
                Size = new Size(130, 32),
                Location = new Point(185, 38),
                BackColor = Color.FromArgb(244, 67, 54),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat
            };
            btnPular.Click += (s, e) => ProximaImagem();

            Button btnSalvar = new Button
            {
                Text = "Salvar Corte",
                Size = new Size(130, 32),
                Location = new Point(355, 38),
                BackColor = Color.FromArgb(76, 175, 80),
                ForeColor = Color.White,
                Font = new Font("Arial", 9, FontStyle.Bold),
                FlatStyle = FlatStyle.Flat
            };
            btnSalvar.Click += (s, e) => SalvarCorte();

            painelControles.Controls.Add(btnZoomOut);
            painelControles.Controls.Add(btnZoomIn);
            painelControles.Controls.Add(btnPular);
            painelControles.Controls.Add(btnSalvar);
            this.Controls.Add(painelControles);

            CarregarArquivosLocais(pastaAtual);
            if (arquivos.Count == 0)
            {
                this.Shown += (s, e) => EscolherImagens();
            }
            else
            {
                CarregarImagemAtual();
            }
        }

        private void ConfigurarEventosCanvas()
        {
            canvasPanel.Paint += CanvasPanel_Paint;

            canvasPanel.MouseDown += (s, e) =>
            {
                if (e.Button == MouseButtons.Left)
                {
                    arrastando = true;
                    startPoint = e.Location;
                    canvasPanel.Focus();
                }
            };

            canvasPanel.MouseMove += (s, e) =>
            {
                if (arrastando)
                {
                    imgX += e.X - startPoint.X;
                    imgY += e.Y - startPoint.Y;
                    startPoint = e.Location;
                    canvasPanel.Invalidate();
                }
            };

            canvasPanel.MouseUp += (s, e) =>
            {
                if (e.Button == MouseButtons.Left)
                    arrastando = false;
            };

            canvasPanel.MouseWheel += (s, e) =>
            {
                double fator = e.Delta > 0 ? 1.15 : 0.85;
                AplicarZoom(fator);
            };
        }

        private void CanvasPanel_Paint(object sender, PaintEventArgs e)
        {
            Graphics g = e.Graphics;

            if (imgMaster != null)
            {
                g.InterpolationMode = InterpolationMode.Bilinear;
                int larg = (int)(imgMaster.Width * zoomFator);
                int alt = (int)(imgMaster.Height * zoomFator);
                g.DrawImage(imgMaster, imgX, imgY, larg, alt);
            }

            int x0 = (canvasLargura - tamanhoAlvo) / 2;
            int y0 = (canvasAltura - tamanhoAlvo) / 2;
            int x1 = x0 + tamanhoAlvo;
            int y1 = y0 + tamanhoAlvo;

            using (SolidBrush brushSombra = new SolidBrush(Color.FromArgb(128, 0, 0, 0)))
            {
                g.FillRectangle(brushSombra, 0, 0, canvasLargura, y0);
                g.FillRectangle(brushSombra, 0, y1, canvasLargura, canvasAltura - y1);
                g.FillRectangle(brushSombra, 0, y0, x0, tamanhoAlvo);
                g.FillRectangle(brushSombra, x1, y0, canvasLargura - x1, tamanhoAlvo);
            }

            using (Pen penBorda = new Pen(Color.Red, 2))
            {
                g.DrawRectangle(penBorda, x0, y0, tamanhoAlvo, tamanhoAlvo);
            }
        }

        private void EscolherImagens()
        {
            using (OpenFileDialog dialog = new OpenFileDialog())
            {
                dialog.Title = "Selecione as Imagens";
                dialog.Multiselect = true;
                dialog.Filter = "Imagens (*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.tif;*.tiff)|*.jpg;*.jpeg;*.png;*.bmp;*.gif;*.tif;*.tiff";

                if (dialog.ShowDialog() == DialogResult.OK && dialog.FileNames.Length > 0)
                {
                    arquivos.Clear();
                    arquivos.AddRange(dialog.FileNames);
                    indiceAtual = 0;

                    string diretorioOrigem = Path.GetDirectoryName(dialog.FileNames[0]);
                    pastaSaida = Path.Combine(diretorioOrigem, "rostos_recortados");
                    if (!Directory.Exists(pastaSaida))
                    {
                        Directory.CreateDirectory(pastaSaida);
                    }

                    CarregarImagemAtual();
                }
            }
        }

        private void CarregarArquivosLocais(string pasta)
        {
            string[] formatos = { ".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tif", ".tiff" };
            if (Directory.Exists(pasta))
            {
                var files = Directory.GetFiles(pasta)
                    .Where(f => formatos.Contains(Path.GetExtension(f).ToLower()))
                    .ToArray();
                arquivos.AddRange(files);
            }
        }

        private void CarregarImagemAtual()
        {
            if (indiceAtual >= arquivos.Count)
            {
                MessageBox.Show("Todas as imagens foram processadas!", "Fim", MessageBoxButtons.OK, MessageBoxIcon.Information);
                labelInfo.Text = "Fim da fila de imagens.";
                if (imgMaster != null) { imgMaster.Dispose(); imgMaster = null; }
                canvasPanel.Invalidate();
                return;
            }

            string caminho = arquivos[indiceAtual];
            labelInfo.Text = string.Format("Processando ({0}/{1}): {2}", indiceAtual + 1, arquivos.Count, Path.GetFileName(caminho));

            try
            {
                if (imgMaster != null) { imgMaster.Dispose(); }
                using (var stream = new FileStream(caminho, FileMode.Open, FileAccess.Read))
                {
                    imgMaster = Image.FromStream(stream);
                }

                zoomFator = 1.0;
                imgX = (canvasLargura - imgMaster.Width) / 2;
                imgY = (canvasAltura - imgMaster.Height) / 2;
                canvasPanel.Invalidate();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Erro ao carregar imagem: " + ex.Message, "Erro", MessageBoxButtons.OK, MessageBoxIcon.Error);
                ProximaImagem();
            }
        }

        private void AplicarZoom(double multiplicador)
        {
            if (imgMaster == null) return;

            double novoFator = zoomFator * multiplicador;
            int novaLarg = (int)(imgMaster.Width * novoFator);
            int novaAlt = (int)(imgMaster.Height * novoFator);

            if (novaLarg < 50 || novaAlt < 50) return;

            double centroCanvasX = canvasLargura / 2.0;
            double centroCanvasY = canvasAltura / 2.0;

            imgX = (int)(centroCanvasX - (centroCanvasX - imgX) * multiplicador);
            imgY = (int)(centroCanvasY - (centroCanvasY - imgY) * multiplicador);

            zoomFator = novoFator;
            canvasPanel.Invalidate();
        }

        private void SalvarCorte()
        {
            if (imgMaster == null) return;

            int x0Quadro = (canvasLargura - tamanhoAlvo) / 2;
            int y0Quadro = (canvasAltura - tamanhoAlvo) / 2;

            using (Bitmap corteFinal = new Bitmap(tamanhoAlvo, tamanhoAlvo))
            {
                using (Graphics g = Graphics.FromImage(corteFinal))
                {
                    g.Clear(Color.White);
                    g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = SmoothingMode.HighQuality;
                    g.PixelOffsetMode = PixelOffsetMode.HighQuality;

                    int posRelativaX = imgX - x0Quadro;
                    int posRelativaY = imgY - y0Quadro;
                    int largRedimensionada = (int)(imgMaster.Width * zoomFator);
                    int altRedimensionada = (int)(imgMaster.Height * zoomFator);

                    g.DrawImage(imgMaster, posRelativaX, posRelativaY, largRedimensionada, altRedimensionada);
                }

                string arqOriginal = arquivos[indiceAtual];
                string caminhoSaida = Path.Combine(pastaSaida, Path.GetFileName(arqOriginal));

                string ext = Path.GetExtension(arqOriginal).ToLower();
                ImageFormat formato = (ext == ".jpg" || ext == ".jpeg") ? ImageFormat.Jpeg : ImageFormat.Png;

                corteFinal.Save(caminhoSaida, formato);
            }

            ProximaImagem();
        }

        private void ProximaImagem()
        {
            indiceAtual++;
            CarregarImagemAtual();
        }

        [STAThread]
        public static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new AplicativoRecorteZoomAmpliado());
        }
    }

    public class CanvasDuploBuffer : Panel
    {
        public CanvasDuploBuffer()
        {
            this.DoubleBuffered = true;
            this.SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.OptimizedDoubleBuffer, true);
            this.UpdateStyles();
        }
    }
}