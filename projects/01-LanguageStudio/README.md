# Projeto 01 - Análise de sentimentos com Language Studio no Azure AI

Plataforma visual e interativa que permite explorar e aplicar recursos de Processamento de Linguagem Natural (NLP) através de uma análise semântica de texto e de fala.

### Principais recursos do Speech Studio:

|     |     |     |
| --- | --- | --- |
| RECURSO | O QUE FAZ | EXEMPLOS PRÁTICOS |
| Extração de informações. | Identifica entidades como nomes, datas, locais e organizações em textos. | Relatórios médicos, contratos, currículos. |
| Classificação de texto. | Categoriza textos com base em temas definidos. | Feedback de clientes, triagem de chamados. |
| Compreensão de perguntas. | Entende e responde perguntas em linguagem natural. | Chatbots, FAQs, assistentes virtuais. |
| Resumo de textos. | Gera resumos automáticos de textos longos. | Relatórios financeiros, artigos técnicos. |
| Análise de sentimentos. | Detecta emoções (positivo, negativo, neutro) em textos. | Avaliação de produtos, redes sociais. |
| Extração de Palavras-chave. | Identifica os termos mais relevantes de um texto. | Análise de tendências, SEO, relatórios. |
| Tradução de documentos. | Traduz arquivos em lote entre idiomas. | Documentos corporativos, manuais técnicos. |
| Transcição de chamadas. | Transcreve e analise gravações de call centers. | Atendimento ao cliente, análise de desempenho. |

### Playground de Fala ( Language Studio )

<p align="center">
  <img src="/images/projeto01/SpeechStudio01.jpg" alt="Página principal Azure AI Speech" style="max-width: 100%;">
  <br>
  <em>Figura 1 - Página principal Azure AI Speech</em>
</p>

Clicando no botão “usar serviço” será aberta uma nova janela onde será configurada a criação de um novo Projeto. Nesta etapa serão descritos o nome do projeto, tipo de assinatura da conta Azure, seleção ou criação de um grupo de recursos, definição da região onde está o serviço bem como o nome do recurso dentro do IA Foundry.

<p align="center">
  <img src="/images/projeto01/SpeechStudio02.jpg" alt="Criação de projeto e configurações de recursos" style="max-width: 100%;">
  <br>
  <em>Figura 2 - Criação de projeto e configurações de recursos</em>
</p>

Após a criação de um novo grupo de recursos “rg-speechstudio” e demais configurações da tela anterior para uso nesse projeto, será aberta a tela do Playground de Fala do Azure AI Foundry.

<p align="center">
  <img src="/images/projeto01/SpeechStudio03.jpg" alt="Playground de Fala" style="max-width: 100%;">
  <br>
  <em>Figura 3 - Playground de Fala</em>
</p>

Em seguida para execução desse projeto, será selecionada a opção “Conversação de fala em texto” e na sequência a opção “Transcrição em tempo real”.

Foi criado um arquivo de áudio no idioma português (pt-br) com uma simples frase para teste. Dentro do painel foram definidas as seguintes configurações:

- **Idioma a ser transcrito:** Português (Brasil) – arquivo de áudio contendo texto nesse idioma.
- **Identificação de idioma:** Desligado – uma vez que é conhecido o idioma do arquivo e não possuir idiomas diferentes falados dentro do mesmo arquivo
- **Diarização do alto-falante:** Desligado – não existe a necessidade de divisão de locutores, uma vez que existe apenas uma voz em específica no áudio.
- **Formato de saída:** Simples
- **Lista de frases:** Ligar – Uma vez que foi utilizada a palavra “Azure” no texto, a mesma foi inserida na lista de palavras conhecidas, afim de ajudar no processo de detecção e transcrição do áudio.
- **Carregar arquivos:** Opção de enviar o(s) arquivo(s) de áudio(s) para a plataforma ou mesmo realizar uma gravação.
- **Arquivos de áudio:** Permite a execução ou descarte dos mesmos. Uma vez que os controles de configurações são alterados, é necessário executar novamente o processo para detecção e transcrição da fala para texto.

Na sequência, é possível identificar o texto sendo transcrito na janela lateral, bem como é possível escutar o(s) áudio(s) e obter tanto o arquivo em texto transcrito como em formato .json.

<p align="center">
  <img src="/images/projeto01/SpeechStudio04.jpg" alt="Tela do Playground com transcrição realizada" style="max-width: 100%;">
  <br>
  <em>Figura 4 - Tela do Playground com transcrição realizada</em>
</p>


<p align="center">
  <img src="/images/projeto01/SpeechStudio05.jpg" alt="Arquivo no formato .json gerado à partir da transcrição do áudio" style="max-width: 100%;">
  <br>
  <em>Figura 5 - Arquivo no formato .json gerado à partir da transcrição do áudio</em>
</p>


### Análise de Sentimentos e Opiniões ( Language Studio )

É um serviço dentro do Azure AI Foundry que permite realizar uma análise sentimental de textos e rotular os mesmos como “negativos”, “neutros” ou “positivos” conforme os sentimentos expressados na escrita.

<p align="center">
  <img src="/images/projeto01/SpeechStudio06.jpg" alt="Tela principal do Playground de Análise de Sentimentos no Azure AI Foundry" style="max-width: 100%;">
  <br>
  <em>Figura 6 - Tela principal do Playground de Análise de Sentimentos no Azure AI Foundry</em>
</p>

Dentro do Azure AI Foundry, acessar a área de Playgrounds, escolher a opção de “Classificar Texto” e em seguida Análise de Sentimento.

É possível realizar as seguintes configurações:

- Selecionar a versão da API: Versão da API utilizada pelo modelo que será utilizada.
- Versão do modelo: Versão do modelo da API.
- Selecionar o idioma do texto: Idioma do texto onde se deseja extrair os sentimentos.

A opção de “Habilitar mineração de opnião” permite identificar dentro do texto pontos chaves positivos, negativos e neutros permitindo uma melhor análise e identificação de tais pontos afim de permitir que melhorias pontuais em determinadas situações ou mesmo analisar destaques positivos e desenvolver ações que reforcem tais qualidades para seus clientes.

O texto utilizado foi o de exemplo da plataforma:

“ I bought a size S and it fit perfectly. I found the zipper a little bit difficult to get up & down due to the side rushing. The color and material are beautiful in person. Amazingly comfortable! “

Que em tradução livre para o português (pt-br) significa:

“ Comprei um tamanho S e coube perfeitamente. Achei o zíper um pouco difícil de subir e descer devido ao babado lateral. A cor e o material são lindos pessoalmente. Incrivelmente confortável! “

<p align="center">
  <img src="/images/projeto01/SpeechStudio07.jpg" alt="Arquivo no formato .json gerado à partir da transcrição do áudio" style="max-width: 100%;">
  <br>
  <em>Figura 7 - Análise de Sentimento realizada com Mineração de Opniões</em>
</p>

O recurso de “Habilitar mineração de opnião” permite identificar não apenas o sentimento geral expressado no texto, que no caso foi 73% positivo e 2% neutro e 25% negativo, mas permite identificar exatamente os pontos positivos, neutros e negativos dentro do mesmo.

Além disso, o recurso quebra o texto em frases para que se possa realizar uma análise de sentimentos individualmente em cada uma, permitindo dessa forma localizar os pontos chaves de cada análise sentimental.

- **Sentimento geral:** Análise sentimental em todo o texto: **73% Positivo, 2% Neutro, 25% Negativo**
- **Frase 1:** “I bought a size S and it fit perfectly” – **97% Positivo**
- **Frase 2:** “I found the zipper a little bit difficult to get up & down due to the side rushing” – **100% Negativo – Ponto chave negativo: Dificuldades com o Zíper**
- **Frase 3:** “The color and material are beautiful in person” – **95% Positiva – Ponto chave positivo: A cor e o material usado**
- **Frase 4:** “Amazingly comfortable!” – **100% Positiva**

Os pontos de avaliação usados pelo modelo utilizam de um método de “Destino / Avaliação” que permite a identificação do sentimento. Esse método de “Chave/Valor” que permite que o modelo de análise de sentimentos consiga interpretar os mesmos dentro do texto.