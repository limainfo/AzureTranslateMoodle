# AzureTranslateMoodle
Using AI to translate questions on LMS Moodle.
# Documentação do Projeto de Tradução com Azure

## Descrição do Projeto
Este projeto foi desenvolvido em Embarcadero Delphi 12 com o objetivo de criar um software de tradução automática utilizando a IA de tradução da Azure. O software é multiplataforma, permitindo a execução em Windows, Android e Linux, e foi projetado para traduzir enunciados de questões criadas no LMS Moodle, que utiliza banco de dados MySQL.

## Estrutura do Projeto

### Diagrama de Classes
![Diagrama de Classes](diagrama_classes.png)

**Principais classes e responsabilidades:**
- **TFormPrincipal**: Classe principal que gerencia a interface gráfica e os eventos dos componentes.
- **TRESTClient**: Componente que realiza as requisições REST para os serviços da Azure.
- **TComboBox**: Exibe as opções de idiomas de origem e destino.
- **TConfigManager**: Responsável por carregar e gerenciar os dados de configuração a partir do arquivo `config.xml`.
- **TDatabaseConnector**: Gerencia a conexão com o banco de dados MySQL.

### Diagrama de Sequência
![Diagrama de Sequência](diagrama_sequencia.png)

**Explicação da Sequência**:
1. O executável é iniciado e o arquivo `config.xml` é extraído, junto com a biblioteca `mariadb.dll`.
2. Os dados do `config.xml` são lidos e utilizados para configurar as conexões REST e de banco de dados.
3. O software se conecta ao endpoint `https://api.cognitive.microsofttranslator.com/languages` para listar os idiomas suportados e exibi-los no `ComboBox` Source Language.
4. O `ComboBox` Source Language seleciona automaticamente o idioma padrão `en` (English), gerando um evento OnChange que carrega os idiomas suportados para tradução.
5. O `ComboBox` Destination Language é preenchido com os idiomas traduzíveis com base no idioma de origem selecionado.
6. O usuário insere o ID da questão do Moodle e clica em `Translate`.
7. O software faz a conexão com o banco de dados MySQL do Moodle e obtém o texto do enunciado da questão.
8. O texto obtido é enviado ao endpoint `https://api.cognitive.microsofttranslator.com/detect` para verificação do idioma e compatibilidade de tradução.
9. Se a tradução for suportada, o texto é enviado ao endpoint `https://api.cognitive.microsofttranslator.com/translate` e o resultado é exibido no Memo Translated.

## Estrutura do Arquivo `config.xml`
```xml
<Config>
  <AzureAI>
    <BaseUrlLanguages>https://api.cognitive.microsofttranslator.com/languages</BaseUrlLanguages>
    <BaseUrlLanguageScope>https://api.cognitive.microsofttranslator.com/languages</BaseUrlLanguageScope>
    <BaseUrlDetect>https://api.cognitive.microsofttranslator.com/detect</BaseUrlDetect>
    <BaseUrlTranslate>https://api.cognitive.microsofttranslator.com/translate</BaseUrlTranslate>
    <ContentTypeHeader>Content-Type</ContentTypeHeader>
    <ContentTypeValue>application/json</ContentTypeValue>
    <SubscriptionKeyHeader>Ocp-Apim-Subscription-Key</SubscriptionKeyHeader>
    <SubscriptionKeyValue>YOUR_SUBSCRIPTION_KEY</SubscriptionKeyValue>
    <SubscriptionRegionHeader>Ocp-Apim-Subscription-Region</SubscriptionRegionHeader>
    <SubscriptionRegionValue>brazilsouth</SubscriptionRegionValue>
  </AzureAI>
  <MySQL>
    <Host>localhost</Host>
    <Database>moodle</Database>
    <User>root</User>
    <Password>password</Password>
  </MySQL>
</Config>
```

## Como Utilizar
1. **Configuração Inicial**: Configure o arquivo `config.xml` de acordos com os enpoints e credencias utilizadas na Azure e os dados da conexão com seu banco de dados MySql do Moodle.
2. **Interface Gráfica**:
   - **Source Language**: Escolha o idioma de origem.
   - **Destination Language**: O idioma de destino será carregado automaticamente.
   - **ID da Questão**: Insira o ID da questão do Moodle.
   - **Botão `Translate`**: Clique para iniciar a tradução.
3. **Execução**:
   - O sistema obtém o texto do enunciado do banco de dados.
   - Detecta o idioma e verifica a tradutibilidade.
   - Traduz o texto e exibe o resultado no Memo Translated.

## Contribuição
Sinta-se à vontade para enviar `pull requests` ou abrir `issues` para sugerir melhorias. Este projeto é uma ótima oportunidade para aprender e explorar a integração do Delphi com APIs REST modernas.

## Licença
Este projeto está licenciado sob a [MIT License](LICENSE).

