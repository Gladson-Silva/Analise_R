# 📊 Dashboard Interativo para Análise Exploratória de Dados em R
Este projeto de portfólio consiste em uma aplicação web desenvolvida em R com o framework Shiny. A ferramenta foi criada para automatizar e agilizar a etapa inicial e crucial da Análise Exploratória de Dados (AED), permitindo que analistas e cientistas de dados obtenham insights rápidos sobre a qualidade e a estrutura de seus conjuntos de dados.


## 📜 Descrição do Projeto
Em qualquer projeto de dados, a primeira fase envolve entender as variáveis, identificar problemas como dados faltantes `Nan`, verificar os tipos de dados e visualizar as distribuições. Este processo, embora vital, pode ser repetitivo. Esta aplicação centraliza essas tarefas em uma interface única e interativa.

O usuário simplesmente faz o upload de um arquivo CSV ou Excel e o dashboard gera automaticamente uma série de análises e visualizações, fornecendo um diagnóstico completo em segundos.

## ✨ Funcionalidades Principais
- 📤 Upload Flexível: Suporte para arquivos `.csv`,`.xls`,`.xlsx` com limite de 100 MB, com opções customizáveis para importação de CSVs.
- 📑 Visão Geral: Apresentação imediata das dimensões do dataset (linhas e colunas) e uma tabela interativa para explorar os dados.
- ❗ Análise de Dados Faltantes: Resumos tabulares e um gráfico de `upset` para identificar não apenas a quantidade de `NAs` por coluna, mas também as combinações de ausência entre elas.
- 🔍 Análise por Coluna: Geração automática de resumos estatísticos para variáveis numéricas e contagem de frequência para variáveis categóricas.
- 📈 Visualização Dinâmica: Um explorador de variáveis que gera histogramas (para dados numéricos) ou gráficos de barras (para dados categóricos) para qualquer coluna selecionada.
- ⚙️ Interface Profissional: Layout responsivo e organizado construído com `shinydashboard`, proporcionando uma experiência de usuário limpa e profissional.

## 🛠️ Tecnologias Utilizadas
- **Linguagem:** R
- **Framework Web:** Shiny
### Bibliotecas Principais:
- `shinydashboard`: Para o layout do painel.
- `dplyr`: Para manipulação de dados.
- `ggplot2`: Para a criação dos gráficos.
- `DT`: Para as tabelas interativas.
- `readxl`: Para a leitura de arquivos Excel.
- `naniar`: Para a análise de dados faltantes.

## 🚀 Como Executar Localmente
1. **Clone o Repositório:**

```bash
git clone https://github.com/Gladson-Silva/Analise_R.git
```
2.**Abra no RStudio:** Navegue até a pasta do projeto e abra o arquivo app.R.
3.**Instale as Dependências:** Execute o seguinte comando no console do R para instalar todas as bibliotecas necessárias:
```R
install.packages(c("shiny", "shinydashboard", "readxl", "dplyr", "DT", "ggplot2", "naniar"))
```
4.**Execute a Aplicação:** Clique no botão "Run App" no canto superior do editor do RStudio.

## 🌱 Próximos Passos (Melhorias Futuras)
Este projeto tem uma base sólida e pode ser expandido com novas funcionalidades, como:

- **[ ] Ferramentas de Limpeza:** Implementar botões para remover duplicados ou tratar NAs (com média, mediana, etc.).
- **[ ] Análise de Correlação:** Adicionar uma aba com um heatmap de correlação entre as variáveis numéricas.
- **[ ] Exportação de Dados:** Incluir um botão para fazer o download do dataset após a limpeza.
- **[ ] Implantação na Nuvem:** Publicar o aplicativo no shinyapps.io para acesso público.

## 🤝 Agradecimentos
Este projeto foi desenvolvido como parte dos meus estudos em R, com a colaboração e a assistência da inteligência artificial Gemini do Google para a prototipagem, depuração e desenvolvimento do código.
