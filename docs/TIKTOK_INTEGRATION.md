# Integração TikTok Live — planejamento seguro

## Estado atual
O jogo funciona com **eventos simulados localmente**. Não existe conexão ativa com TikTok, leitura de presentes reais ou acesso à conta.

## Para ativar eventos reais
1. Obter acesso autorizado ao produto/API TikTok Live Interactive aplicável.
2. Validar termos, permissões, políticas de presentes e transmissão.
3. Implementar serviço de backend com tokens guardados apenas no servidor.
4. Validar assinaturas de webhook/eventos, limitar taxas e filtrar spam.
5. Transmitir ao jogo apenas eventos normalizados e não sensíveis.

## Eventos internos propostos
- like: aumenta nitro com limite
- comment: aumenta hype, sem exibir texto não moderado
- gift: ativa efeito visual, sem prometer prêmio
- follow: mostra contador agregado

Não use bots, scraping não autorizado, compra de engajamento ou sorteios baseados em presentes. Não coloque credenciais no repositório.
