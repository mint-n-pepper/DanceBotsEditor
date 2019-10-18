# Style Guide

## Naming

| Element 	| Example | Comment |
| ------- 	| ------- | ------- |
| Variable 	| `fileName` | camelCase |
| Member Variable | `mFileName` | m + CamelCase|
| Constant	| `fileName` | like variable | 
| Enum | `eWriteOnly` | e + CamelCase|
| Class | `FileHandler` | CamelCase|
| Files | `FileHandler.h` | CamelCase + file ending|

## Indentation / Tabs
are two spaces.

## Function Doc

Use following template:
```cpp
	/**
	\brief  Calculate convolution of two signals.
			
			Some more detailed description or an example goes here.
	\param[in] Signal A
	\param[in] Signal B
	\param[out] Convolution A * B
	\return Whether the operation was successful (0) or not (1).
	*/
```

## Header Guards
Use the standard define guards, e.g.
```cpp
	#ifndef AUDIO_FILE_H_
	#define AUDIO_FILE_H_

	#endif // AUDIO_FILE_H_
```