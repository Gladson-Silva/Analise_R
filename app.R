# =========================================================================
# PROJETO PORTFÓLIO: DASHBOARD PARA ANÁLISE EXPLORATÓRIA DE DADOS
# AUTOR: Gladson Silva (Desenvolvido em colaboração com a IA Gemini)
# DATA: 16 de agosto de 2025
# VERSÃO: 3.0 (Versão final para portfólio)
#
# DESCRIÇÃO: 
#   Esta aplicação Shiny constrói um dashboard interativo que permite 
#   a um usuário fazer o upload de um arquivo de dados (CSV ou Excel) e 
#   receber uma análise exploratória automática. O objetivo é acelerar 
#   o processo inicial de entendimento e diagnóstico da qualidade dos dados.
# =========================================================================


# --- 1. CONFIGURAÇÕES GLOBAIS E BIBLIOTECAS ---

# Define o limite máximo de tamanho para upload de arquivos (100 MB)
options(shiny.maxRequestSize = 100*1024^2)

# Carrega todas as bibliotecas necessárias para a aplicação
library(shiny)          # Framework principal para criar a aplicação web
library(shinydashboard) # Para criar o layout de dashboard profissional
library(readxl)         # Para ler arquivos Excel (.xls, .xlsx)
library(dplyr)          # Para manipulação e transformação de dados
library(DT)             # Para criar tabelas de dados interativas em HTML
library(ggplot2)        # Para a criação de gráficos declarativos e elegantes
library(naniar)         # Especializada em visualização de dados faltantes (NAs)


# =========================================================================
# 2. INTERFACE DO USUÁRIO (UI)
# Define a aparência e o layout da aplicação usando shinydashboard.
# =========================================================================
ui <- dashboardPage(
  # Define o tema de cor do dashboard
  skin = "blue", 
  
  # --- Cabeçalho ---
  dashboardHeader(title = "Análise de Dados"),
  
  # --- Barra Lateral ---
  dashboardSidebar(
    # Define o menu de navegação lateral
    sidebarMenu(
      # Cada menuItem é um link para uma aba e possui um ícone
      menuItem("Visão Geral", tabName = "visao_geral", icon = icon("table-list")),
      menuItem("Análise de NAs", tabName = "analise_na", icon = icon("triangle-exclamation")),
      menuItem("Análise por Coluna", tabName = "analise_coluna", icon = icon("magnifying-glass-chart")),
      menuItem("Visualização Gráfica", tabName = "visualizacao", icon = icon("chart-simple")),
      
      # Divisor visual
      tags$hr(style="border-color: grey;"),
      
      # --- Controles de Input ---
      # Input para o usuário fazer o upload do arquivo
      fileInput("arquivo", "Faça o upload do arquivo", accept = c(".csv", ".xls", ".xlsx")),
      
      # Inputs condicionais para arquivos CSV
      h5("Opções para CSV"),
      checkboxInput("header", "O arquivo contém cabeçalho?", TRUE),
      radioButtons("sep", "Separador de colunas:", choices = c(Virgula = ",", `Ponto e Vírgula` = ";", Tab = "\t"), selected = ","),
      
      # Input condicional para arquivos Excel (gerado no server)
      h5("Opções para Excel"),
      uiOutput("seletor_planilha")
    )
  ),
  
  # --- Corpo do Dashboard ---
  dashboardBody(
    # Define que o corpo conterá o conteúdo das abas definidas no menu
    tabItems(
      # Conteúdo da Aba 1: Visão Geral
      tabItem(tabName = "visao_geral",
              fluidRow(
                # 'box' é um container para organizar o conteúdo
                box(title = "Informações Gerais do Arquivo", status = "primary", solidHeader = TRUE, width = 12, verbatimTextOutput("resumo_geral")),
                box(title = "Amostra Interativa dos Dados", status = "primary", solidHeader = TRUE, width = 12, DTOutput("tabela_dados"))
              )
      ),
      
      # Conteúdo da Aba 2: Análise de NAs
      tabItem(tabName = "analise_na",
              fluidRow(
                box(title = "Contagem de Dados Faltantes (NA) por Coluna", status = "warning", solidHeader = TRUE, width = 6, verbatimTextOutput("resumo_na")),
                box(title = "Linhas em Branco (Completamente Vazias)", status = "warning", solidHeader = TRUE, width = 6, verbatimTextOutput("linhas_branco")),
                box(title = "Visualização de Combinações de Dados Faltantes", status = "warning", solidHeader = TRUE, width = 12, plotOutput("plot_na"))
              )
      ),
      
      # Conteúdo da Aba 3: Análise por Coluna
      tabItem(tabName = "analise_coluna",
              fluidRow(
                box(title = "Estrutura e Tipos de Dados (str)", status = "info", solidHeader = TRUE, width = 12, verbatimTextOutput("tipos_dados")),
                box(title = "Resumo Estatístico (Colunas Numéricas)", status = "info", solidHeader = TRUE, width = 6, verbatimTextOutput("resumo_numerico")),
                box(title = "Contagem de Valores Únicos (Colunas Categóricas)", status = "info", solidHeader = TRUE, width = 6, verbatimTextOutput("resumo_categorico"))
              )
      ),
      
      # Conteúdo da Aba 4: Visualização
      tabItem(tabName = "visualizacao",
              fluidRow(
                box(title = "Explore uma Variável de Cada Vez", status = "success", solidHeader = TRUE, width = 12,
                    # Seletor de coluna dinâmico, gerado no server
                    uiOutput("seletor_coluna_visualizacao"),
                    # Espaço para renderizar o gráfico
                    plotOutput("grafico_coluna", height = "500px")
                )
              )
      )
    )
  )
)


# =========================================================================
# 3. LÓGICA DO SERVIDOR (Server)
# Contém toda a lógica reativa: como os dados são lidos, processados
# e como os outputs (gráficos, tabelas) são gerados.
# =========================================================================
server <- function(input, output, session) {
  
  # --- Reatividade Principal: Carregamento dos Dados ---
  # 'reactive' cria um objeto que se atualiza automaticamente quando
  # seus inputs (neste caso, input$arquivo) mudam.
  dados <- reactive({
    # Garante que a execução só continue se um arquivo for enviado
    req(input$arquivo)
    
    caminho <- input$arquivo$datapath
    extensao <- tools::file_ext(caminho)
    
    # 'switch' usa a extensão do arquivo para decidir qual função de leitura usar
    switch(extensao,
           csv = read.csv(caminho, header = input$header, sep = input$sep, stringsAsFactors = FALSE),
           xls = read_excel(caminho, sheet = input$planilha_selecionada),
           xlsx = read_excel(caminho, sheet = input$planilha_selecionada),
           # Mensagem de erro se o formato for inválido
           validate("Formato de arquivo não suportado.")
    )
  })
  
  # --- Geração de UI Dinâmica ---
  # Cria o seletor de planilhas do Excel apenas se um arquivo Excel for carregado.
  output$seletor_planilha <- renderUI({
    req(input$arquivo)
    extensao <- tools::file_ext(input$arquivo$name)
    if (extensao %in% c("xls", "xlsx")) {
      selectInput("planilha_selecionada", "Selecione a Planilha",
                  choices = excel_sheets(input$arquivo$datapath))
    }
  })
  
  # --- Geração dos Outputs para a Aba "Visão Geral" ---
  output$resumo_geral <- renderPrint({
    df <- dados() # Acessa os dados reativos
    cat("Nome do Arquivo:", input$arquivo$name, "\n")
    cat("Número de Linhas:", nrow(df), "\n")
    cat("Número de Colunas:", ncol(df), "\n")
  })
  output$tabela_dados <- renderDT({
    datatable(dados(), options = list(pageLength = 10, scrollX = TRUE, searching = FALSE))
  })
  
  # --- Geração dos Outputs para a Aba "Análise de NAs" ---
  output$resumo_na <- renderPrint({
    df <- dados()
    miss_summary <- naniar::miss_var_summary(df)
    print(miss_summary)
  })
  output$linhas_branco <- renderPrint({
    df <- dados()
    linhas_brancas <- which(rowSums(is.na(df)) == ncol(df))
    if (length(linhas_brancas) > 0) {
      cat("Total de linhas completamente em branco:", length(linhas_brancas), "\n")
      cat("Índices (linhas):", paste(linhas_brancas, collapse = ", "), "\n")
    } else {
      cat("Nenhuma linha completamente em branco foi encontrada.\n")
    }
  })
  output$plot_na <- renderPlot({
    df <- dados()
    # 'validate' e 'need' exibem mensagens amigáveis em vez de erros
    validate(
      need(any(is.na(df)), "✅ Boa notícia: Não há dados faltantes (NAs) no seu arquivo!"),
      need(sum(colSums(is.na(df)) > 0) >= 2, "O gráfico 'upset' não foi gerado porque requer que pelo menos DUAS colunas tenham dados faltantes.")
    )
    gg_miss_upset(df)
  })
  
  # --- Geração dos Outputs para a Aba "Análise por Coluna" ---
  output$tipos_dados <- renderPrint({ str(dados()) })
  output$resumo_numerico <- renderPrint({
    df_num <- select_if(dados(), is.numeric)
    if (ncol(df_num) > 0) { summary(df_num) } else { "Nenhuma coluna numérica encontrada." }
  })
  output$resumo_categorico <- renderPrint({
    df_cat <- select_if(dados(), Negate(is.numeric))
    if (ncol(df_cat) > 0) {
      lapply(df_cat, function(col) {
        list(`Valores Únicos` = n_distinct(col), `Top 5 Frequentes` = head(sort(table(col, useNA = "ifany"), decreasing = TRUE), 5))
      })
    } else { "Nenhuma coluna categórica encontrada." }
  })
  
  # --- Geração dos Outputs para a Aba "Visualização" ---
  output$seletor_coluna_visualizacao <- renderUI({
    req(dados())
    selectInput("coluna_selecionada", "Selecione uma Coluna para Visualizar:", choices = names(dados()), width = "100%")
  })
  output$grafico_coluna <- renderPlot({
    req(dados(), input$coluna_selecionada)
    df <- dados()
    coluna_nome <- input$coluna_selecionada
    
    # Lógica condicional: gera um gráfico diferente com base no tipo de dado da coluna
    if (is.numeric(df[[coluna_nome]])) {
      # Histograma para dados numéricos
      ggplot(df, aes(x = .data[[coluna_nome]])) +
        geom_histogram(bins = 30, fill = "darkgreen", color = "white", alpha = 0.7) +
        labs(title = paste("Distribuição de", coluna_nome), x = coluna_nome, y = "Frequência") +
        theme_minimal(base_size = 14)
    } else {
      # Gráfico de barras para dados categóricos (mostrando apenas os top 20)
      df %>%
        filter(!is.na(.data[[coluna_nome]])) %>%
        count(.data[[coluna_nome]], sort = TRUE) %>%
        top_n(20, wt = n) %>%
        ggplot(aes(x = reorder(.data[[coluna_nome]], n), y = n)) +
        geom_bar(stat = "identity", fill = "purple", alpha = 0.8) +
        coord_flip() + # Inverte os eixos para melhor leitura
        labs(title = paste("Contagem das 20 Principais Categorias em", coluna_nome), x = "", y = "Contagem") +
        theme_minimal(base_size = 14)
    }
  })
}


# =========================================================================
# 4. EXECUÇÃO DA APLICAÇÃO
# =========================================================================
shinyApp(ui = ui, server = server)