# Passos de Teste Manual - WorkoutExtras

## Pré-requisitos
- iPhone e Apple Watch emparelhados
- App instalado em ambos os dispositivos
- HealthKit permissões concedidas
- WatchConnectivity funcional

## Teste 1: Fluxo Básico (pathPoints + higherJump)

### Passos
1. **Inicie workout no Apple Watch**
   - Abrir FtvApp no Watch
   - Selecionar "Soccer"
   - Iniciar treino

2. **Simular dados durante treino**
   - Caminhar/correr para gerar trajeto
   - Fazer alguns saltos para registrar jumps
   - Continuar por ~2-3 minutos

3. **Finalizar workout**
   - Apertar "Fim" no Watch
   - Na SummaryView, verificar se aparece "Best Jump"
   - Apertar "Done" → dados são enviados ao iPhone

4. **Verificar no iPhone**
   - Abrir FtvApp no iPhone
   - Aguardar sincronização
   - Navegar para Evolution/Calendar
   - Verificar se o workout aparece com:
     - ✅ higherJump preenchido (valor > 0)
     - ✅ pointsPath preenchido (array não vazio)

### Logs Esperados (iPhone)
```
📩 Recebendo dados para workoutId [UUID]
📩 Recebido jump [valor] para workoutId [UUID]
📍 Recebi [N] pontos do trajeto para workoutId [UUID]
✅ HigherJump salvo para workoutID [UUID]
✅ PointPath salvo para workoutID [UUID]
📦 Fazendo merge de [N] workouts com [N] extras
```

## Teste 2: Condição de Corrida (Ordem Corrigida)

### Passos
1. **Complete um workout** (seguir Teste 1)
2. **Imediatamente após "Done" no Watch**:
   - No iPhone, force refresh dos workouts
   - Ir para Home → puxar para baixo (refresh)
   - OU navegar entre abas rapidamente

3. **Verificar consistência**
   - ✅ Workout deve aparecer COM dados extras
   - ❌ ANTES: aparecia sem dados extras na primeira consulta
   - ✅ DEPOIS: sempre aparece com dados completos

### Teste de Timing
```bash
# Sequência rápida (simula condição de corrida):
1. Watch envia dados → iPhone recebe
2. iPhone imediatamente chama fetchAllWorkouts
3. Dados devem estar presentes (não mais corrida)
```

## Teste 3: Múltiplos Workouts

### Passos
1. **Complete 3-4 workouts** em sequência
   - Cada um com trajetos diferentes
   - Alguns com jumps, outros sem

2. **Verificar lista de workouts**
   - Home → ver workouts recentes
   - Evolution → filtrar por período
   - Calendar → verificar workouts por dia

3. **Validar dados**
   - ✅ Todos os workouts têm seus dados específicos
   - ✅ higherJump varia entre workouts
   - ✅ pointsPath únicos para cada workout
   - ✅ Performance boa (carregamento rápido)

## Teste 4: Upsert (Atualização)

### Cenário
Simular múltiplos envios do mesmo workout (edge case).

### Passos
1. **Complete workout normalmente**
2. **Force re-envio** (se possível):
   - Reiniciar Watch app
   - OU simular novo envio com dados diferentes

3. **Verificar atualização**
   - ✅ higherJump deve ser o MAIOR valor recebido
   - ✅ pointsPath deve ser o ÚLTIMO recebido
   - ✅ Não deve duplicar entradas

## Teste 5: Regressão (higherJump)

### Objetivo
Garantir que `higherJump` continua funcionando como antes.

### Passos
1. **Complete workout com jumps detectados**
2. **Verificar SummaryView no Watch**:
   - ✅ "Best Jump: [valor] cm" aparece
3. **Verificar no iPhone**:
   - ✅ Workout mostra higherJump > 0
   - ✅ Valor corresponde ao mostrado no Watch

## Teste 6: Dados Legados

### Cenário
Verificar compatibilidade com dados existentes.

### Passos
1. **Se houver workouts antigos** no app:
   - Verificar se continuam aparecendo
   - ✅ higherJump de workouts antigos preservado
   - ✅ workouts antigos sem pointsPath (array vazio)

2. **Novos workouts**:
   - ✅ Usam novo sistema (WorkoutExtras)
   - ✅ Têm tanto higherJump quanto pointsPath

## Teste 7: Error Handling

### Cenários de Erro
1. **Watch desconectado**:
   - Dados não enviados → iPhone não quebra
   - ✅ workouts aparecem sem dados extras

2. **SwiftData erro**:
   - Simular disk full (difícil)
   - ✅ App não trava, logs de erro aparecem

3. **Dados malformados**:
   - ✅ pathPoints inválidos são ignorados
   - ✅ higherJump inválido é ignorado

## Teste 8: Integração Automatizada

### Executar Teste Programático
```swift
// No Xcode, adicionar código temporário:
Task {
    await WorkoutExtrasIntegrationTest.run()
}
```

### Logs Esperados
```
🧪 Iniciando teste de integração WorkoutExtras
🔹 1. Persistindo higherJump...
✅ HigherJump salvo para workoutID test-workout-123
🔹 2. Persistindo pointPath...
✅ PointPath salvo para workoutID test-workout-123
🔹 3. Buscando dados extras...
📦 Encontrados 1 WorkoutExtras para 1 workoutIDs
✅ Teste básico passou
🎉 Todos os testes de integração passaram!
```

## Métricas de Sucesso

### Performance
- ⏱️ Tempo de carregamento < 2s para 50 workouts
- 📊 1 query para múltiplos workouts (não N queries)

### Funcionalidade
- ✅ 100% dos workouts com dados corretos
- ✅ Zero perda de dados de higherJump
- ✅ pathPoints chegam completos do Watch

### Estabilidade
- ✅ Sem crashes relacionados a SwiftData
- ✅ Sem condições de corrida visíveis
- ✅ Recuperação graceful de erros

## Troubleshooting

### Se dados não aparecem:
1. Verificar logs no Xcode console
2. Confirmar WatchConnectivity ativo
3. Reiniciar ambos os apps
4. Verificar permissões HealthKit

### Se há inconsistências:
1. Verificar timing de envio Watch → iPhone
2. Confirmar que save é awaited
3. Checar se fetchAllWorkouts vem depois do save

### Performance ruim:
1. Verificar se está usando fetchExtrasMap (não loops)
2. Confirmar queries otimizadas
3. Checar tamanho dos pathPoints arrays
