# AOTO Racing Live — Android

Jogo 3D em Godot 4, feito para começar pelo celular Redmi Note 10S.

## Incluído nesta versão
- Menu de seleção Racing Live / Funk Drift Live
- Corrida automática de dois carros 3D, pista noturna e elementos neon
- Contagem regressiva, 3 voltas, vencedor, HUD e pausa
- Simulação offline de curtidas (nitro), comentários (hype) e presentes (efeitos de boost)
- Configurações locais de velocidade e qualidade (a opção de qualidade é salva; redução gráfica adicional ainda será implementada)
- Renderer Compatibility para Android, sem assets externos

## Executar no Android
1. No GitHub, abra o repositório pelo navegador e escolha Code > Download ZIP.
2. Extraia o ZIP usando um gerenciador de arquivos.
3. No editor Godot Android, toque em Importar e escolha `project.godot`.
4. Execute a cena principal com o botão Play.
5. Use a tela na horizontal.

## Avisos e limites
Este é um jogo **offline jogável em código, ainda não validado no dispositivo**. A conexão com TikTok, autorização de API, presentes reais, transmissão ao vivo, música funk licenciada, efeitos sonoros, física realista, exportação APK e loja de carros NÃO estão implementados. Os carros atuais são modelos geométricos simples.

Não cole tokens do TikTok ou chaves privadas em repositórios públicos. A integração futura deverá utilizar interfaces oficialmente autorizadas e autenticação no backend, sem bots ou engajamento artificial.

## Arquivos
- `project.godot`: configuração do projeto
- `main.tscn`: cena principal
- `game_full.gd`: versão atual do jogo
- `main.gd`: protótipo anterior preservado para referência

## Próximas melhorias
Modelos de carros mais detalhados, áudio original/licenciado, fumaça otimizada, UI responsiva para telas pequenas, integração autorizada e testes de desempenho.
