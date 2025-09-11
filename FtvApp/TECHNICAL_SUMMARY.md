# Resumo Técnico - Implementação WorkoutExtras

## Objetivo
Persistir localmente os `pathPoints` recebidos do Apple Watch em SwiftData, relacionados a um `workoutID` (UUID do HKWorkout), e corrigir a ordem de execução no `fetchAllWorkouts` para evitar condições de corrida.

## Problema Resolvido
**Ordem de execução incorreta**: O código anterior buscava os dados do SwiftData primeiro, depois salvava os novos dados, causando inconsistências quando `fetchAllWorkouts` era chamado imediatamente após receber dados do Watch.

## Solução Implementada

### 1. Novo Modelo SwiftData Unificado
**Arquivo**: `FtvApp/Model/BaseWorkoutModel.swift`

```swift
@Model
final class WorkoutExtras {
    @Attribute(.unique) var workoutID: String   // UUID string do HKWorkout
    var higherJump: Double?                     // maior pulo do treino
    var pointPath: [[Double]]?                  // trajeto como array de pares [x,y]
    var updatedAt: Date
}
```

**Benefícios**:
- Unifica `higherJump` e `pointPath` em uma única entidade
- Usa UUID string como chave (mais eficiente para queries)
- Mantém entidades legadas para compatibilidade
- Estrutura `pointPath` como `[[Double]]` conforme usado no app

### 2. Repository Pattern
**Arquivo**: `FtvApp/ViewModel/WorkoutExtrasRepository.swift`

**Interface**:
```swift
protocol WorkoutExtrasStoring {
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws
    func upsertPointPath(_ path: [[Double]], for workoutID: String) async throws
    func fetchExtrasMap(for workoutIDs: [String]) async throws -> [String: WorkoutExtras]
}
```

**Características**:
- Operações `upsert` idempotentes (create ou update)
- `fetchExtrasMap`: busca múltiplos workouts em uma única query
- Tratamento de erros com `throws`
- Thread-safe com `@MainActor`

### 3. Recepção Corrigida (WatchConnectivity)
**Arquivo**: `FtvApp/ManagerConnect/PhoneWCSessionDelegate.swift`

**Mudanças principais**:
```swift
// ANTES: Busca → Salva → Inconsistência
// DEPOIS: Salva PRIMEIRO → await completion

func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    Task { @MainActor in
        // ✅ Persiste higherJump se presente
        if let valor = message["pulo"] as? Double {
            try await extrasRepository.upsertHigherJump(valor, for: workoutIdString)
        }
        
        // ✅ Persiste pointPath se presente
        if let rawPath = message["workoutPath"] as? [[String: Double]] {
            let pathPoints: [[Double]] = rawPath.compactMap { ... }
            try await extrasRepository.upsertPointPath(pathPoints, for: workoutIdString)
        }
    }
}
```

### 4. HealthManager com Ordem Corrigida
**Arquivo**: `FtvApp/ViewModel/HealthManager.swift`

**Fluxo novo**:
1. **Fetch HealthKit**: Busca workouts básicos
2. **Monta workouts básicos**: Sem dados extras (valores padrão)
3. **Enrichment**: Uma única query para buscar todos os extras
4. **Merge puro**: Combina dados HealthKit + SwiftData (sem side effects)

```swift
private func enrichWorkoutsWithExtras(_ workouts: [Workout]) async -> [Workout] {
    let workoutIDs = workouts.map { $0.id.uuidString }
    let extrasMap = try await extrasRepository.fetchExtrasMap(for: workoutIDs)
    
    return workouts.map { workout in
        if let extras = extrasMap[workout.id.uuidString] {
            return Workout(/* ...com extras.higherJump e extras.pointPath */)
        } else {
            return workout // sem extras
        }
    }
}
```

### 5. Configuração do Container
**Arquivo**: `FtvApp/Views/SplashScreen/MainView.swift`

```swift
// Atualizado para incluir novo modelo
container = try ModelContainer(for: JumpEntity.self, WorkoutPathEntity.self, WorkoutExtras.self)
```

### 6. Teste de Integração
**Arquivo**: `FtvApp/Tests/WorkoutExtrasIntegrationTest.swift`

Cobre:
- ✅ Persistir → buscar → verificar dados
- ✅ Upsert (atualização de dados existentes)
- ✅ Múltiplos workouts
- ✅ Container in-memory para testes

## Melhorias Implementadas

### Escalabilidade
- **Query única**: `fetchExtrasMap` busca dados para múltiplos workouts
- **Indexação**: `@Attribute(.unique)` no `workoutID`
- **Eficiência**: Merge em memória após fetch completo

### Manutenibilidade
- **Repository pattern**: Lógica centralizada e testável
- **Interface clara**: Protocol `WorkoutExtrasStoring`
- **Compatibilidade**: Métodos legados mantidos
- **Logging**: Logs detalhados para debugging

### Consistência
- **Ordem determinística**: Sempre persiste → depois busca
- **Idempotência**: Múltiplas chamadas produzem mesmo resultado
- **Atomic operations**: SwiftData context save aguardado

### Observabilidade
- **Logs estruturados**: Cada operação logada com contexto
- **Error handling**: Tratamento de erros sem quebrar fluxo
- **Performance**: Logs de tempo e contagem de dados

## Compatibilidade

### Zero Breaking Changes
- ✅ Frontend inalterado
- ✅ Estrutura `Workout` mantida
- ✅ APIs públicas preservadas
- ✅ `higherJump` continua funcionando

### Migração Suave
- Entidades legadas (`JumpEntity`, `WorkoutPathEntity`) mantidas
- Dados existentes continuam acessíveis
- Novos dados usam `WorkoutExtras`
- Transição gradual possível

## Critérios de Aceite Atendidos

✅ **Persistência consistente**: `pathPoints` salvos antes de qualquer leitura
✅ **Ordem corrigida**: Não há mais condições de corrida
✅ **Merge eficiente**: Uma query para buscar dados de múltiplos workouts
✅ **Zero regressão**: `higherJump` continua funcionando
✅ **Mudanças mínimas**: Alterações localizadas, sem refatoração ampla
✅ **Testabilidade**: Teste de integração cobrindo fluxo completo

## Performance

### Antes
- N queries individuais (1 por workout)
- Corridas entre save/fetch
- Inconsistências temporárias

### Depois
- 1 query para todos os workouts
- Fetch determinístico após save
- Dados sempre consistentes

## Próximos Passos Sugeridos

1. **Monitoramento**: Acompanhar logs em produção
2. **Migração gradual**: Mover dados legados para `WorkoutExtras`
3. **Cache**: Implementar cache de `extrasMap` se necessário
4. **Cleanup**: Remover entidades legadas após migração completa
