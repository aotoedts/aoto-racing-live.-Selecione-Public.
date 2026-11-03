# AOTO Racing Live — Estado e instalação

## Entregue no GitHub
- Godot 4, renderer Compatibility para Android
- Racing: corrida automática, 3 voltas, placar e vencedor
- Funk Drift: carros derrapando e fumaça leve
- Dois modelos de carros esportivos originais feitos com meshes do Godot
- Iluminação neon, pista noturna, câmera 3D
- Nitro e hype com botões de simulação de curtida/comentário/presente
- Trilha eletrônica e motor sintetizados sem gravações de terceiros
- Menu, pausa, opções salvas, opção de eventos locais
- Adaptador local que aceita somente tipos de evento permitidos e limita o processamento

## Testar no Redmi Note 10S
1. GitHub > Code > Download ZIP.
2. Extraia o ZIP no Android.
3. Abra o editor Godot Android e importe `project.godot`.
4. Abra a cena principal e execute. Use orientação paisagem.
5. Se houver erro, copie a mensagem do painel Output/Debugger.

## Eventos locais (sem TikTok)
O adaptador pode ser ligado nas configurações. Para simular eventos externos, crie o arquivo `user://aoto_events.json` com:
```json
[{"type":"like"},{"type":"comment"},{"type":"gift"}]
```
Ele é lido uma vez e removido; limite de 12 eventos por leitura. O caminho `user://` é a pasta de dados do aplicativo, não a pasta do projeto.

## O que NÃO está pronto
- Conexão oficial TikTok Live e presentes reais: depende de acesso e autorização da plataforma
- APK assinado e publicado: depende de exportação, chaves e testes no Android
- Música funk comercial: exige direitos de uso em transmissão; trilha atual é original e eletrônica
- Gráficos fotorrealistas, colisões realistas, multiplayer e garantia de 30 FPS
- Testes de execução: ainda não realizados no aparelho

Nenhuma credencial deve ser colocada no repositório público. A versão é funcionalidade implementada em código, ainda não validada em execução.
