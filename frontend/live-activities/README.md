# live-activities

j

## Install

```bash
npm install live-activities
npx cap sync
```

## API

<docgen-index>

* [`start(...)`](#start)
* [`update(...)`](#update)
* [`end(...)`](#end)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### start(...)

```typescript
start(options: TimerState) => Promise<{ activityId: string; }>
```

| Param         | Type                                              |
| ------------- | ------------------------------------------------- |
| **`options`** | <code><a href="#timerstate">TimerState</a></code> |

**Returns:** <code>Promise&lt;{ activityId: string; }&gt;</code>

--------------------


### update(...)

```typescript
update(options: TimerState & { activityId: string; }) => Promise<void>
```

| Param         | Type                                                                        |
| ------------- | --------------------------------------------------------------------------- |
| **`options`** | <code><a href="#timerstate">TimerState</a> & { activityId: string; }</code> |

--------------------


### end(...)

```typescript
end(options: { activityId: string; }) => Promise<void>
```

| Param         | Type                                 |
| ------------- | ------------------------------------ |
| **`options`** | <code>{ activityId: string; }</code> |

--------------------


### Interfaces


#### TimerState

| Prop             | Type                        |
| ---------------- | --------------------------- |
| **`startedAt`**  | <code>number</code>         |
| **`endsAt`**     | <code>number \| null</code> |
| **`countsDown`** | <code>boolean</code>        |

</docgen-api>
