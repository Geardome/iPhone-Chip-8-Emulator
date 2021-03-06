/*
 *  Timer.cpp
 *  PuzzleStar
 *
 *  Created by nacho on 19/11/08.
 *  Copyright 2008 d. All rights reserved.
 *
 */

#include "Timer.h"

//--------------------------------------------------------------------
// FunciÛn:    CTimer::CTimer
// PropÛsito:  
// Fecha:      jueves, 09 de noviembre de 2006, 13:27:10
//--------------------------------------------------------------------
CTimer::CTimer(void)
{
	Reset();
}

void CTimer::Reset(void)
{
	mach_timebase_info_data_t timebase;
	mach_timebase_info(&timebase);
	
	m_fResolution = (float)timebase.numer / (float)timebase.denom;
	
	m_fFPS = 0;
	m_bIsRunning = false;
	m_i64StopedTicks = 0;
	m_i64BaseTicks = 0;
	
	m_fLastUpdate = 0;
	m_iFrameCount = 0;
	
	m_fFrameTime = 0;
	m_fDeltaTime = 0;
	
	m_fOffset = 0;
}

//--------------------------------------------------------------------
// FunciÛn:    CTimer::~CTimer
// PropÛsito:  
// Fecha:      jueves, 09 de noviembre de 2006, 13:32:11
//--------------------------------------------------------------------
CTimer::~CTimer(void)
{
	Log("+++ ~CTimer::~CTimer DESTRUIDO\n");
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::Start
// PropÛsito:  Resetea el contador e inicia el cronÛmetro.
// Fecha:      29/07/2004 12:41
//--------------------------------------------------------------------
void CTimer::Start(void)
{
	// Tomamos el tiempo actual para saber en quÈ momento se
	// activÛ el cronÛmetro...probamos primero con el reloj
	// de alta resoluciÛn del PC. Si no existe, usamos timeGetTime
	
	m_i64BaseTicks = mach_absolute_time();
    
	m_bIsRunning = true;
	
	m_fLastUpdate = 0;
	m_iFrameCount = 0;
	
	m_fFrameTime = 0;
	m_fDeltaTime = 0;
	
	m_fOffset = 0;
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::Stop
// PropÛsito:  Para el cronÛmetro.
// Fecha:      29/07/2004 12:41
//--------------------------------------------------------------------
void CTimer::Stop(void)
{
	if(m_bIsRunning)
	{
		// Recuerda cuando se ha parado para poder sacar el tiempo
		// transcurrido en detencion.
		// Probamos primero con el reloj de alta resoluciÛn del PC 
		// Si no existe usamos timeGetTime
		
		m_i64StopedTicks = mach_absolute_time();
		
		m_bIsRunning = false;
	}
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::Continue
// PropÛsito:  Iniciamos el cronÛmetro pero sin resetear las variables.
// Fecha:      29/07/2004 12:41
//--------------------------------------------------------------------
void CTimer::Continue(void)
{
	if(!m_bIsRunning)
	{
		u64 Ticks;		
				
		Ticks = mach_absolute_time();
		
		// Incrementamos m_i64BaseTicks para saber 
		// cu·nto tiempo hemos estado pausados.
		m_i64BaseTicks += Ticks - m_i64StopedTicks;
		
		m_bIsRunning = true;
	}
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::GetActualTime
// PropÛsito:  Devuelve el tiempo actual en segundos.
// Fecha:      29/07/2004 12:41
//--------------------------------------------------------------------
float CTimer::GetActualTime(void)
{
	u64 Ticks;
	
	if(m_bIsRunning)
	{
		Ticks = mach_absolute_time();
	}
	else
		Ticks = m_i64StopedTicks;
	
	// Restamos el tiempo cuando comanzamos para
	// calcular el tiempo que nuestro cronÛmetro
	// ha estado en marcha
	Ticks -= m_i64BaseTicks;
	
	// Devolvemos el tiempo en segundos.
	return ((((float) Ticks) * m_fResolution) / 1000000000.0f) + m_fOffset;
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::Update
// PropÛsito:  Calcula el frame-rate. Esta funciÛn debe llamarse una vez por frame.
// Fecha:      29/07/2004 12:42
//--------------------------------------------------------------------
void CTimer::Update(void)
{
	m_fDeltaTime = GetActualTime() - m_fFrameTime;
	m_fFrameTime += m_fDeltaTime;
	
	// Aumentamos el n∫ de frames
	m_iFrameCount++;
	// Calculamos el frame-rate
	if(m_fFrameTime - m_fLastUpdate > FPS_REFRESH_TIME)
	{
		m_fFPS = m_iFrameCount / (m_fFrameTime - m_fLastUpdate);
		m_iFrameCount = 0;
		m_fLastUpdate = m_fFrameTime;
	}
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::GetFPS
// PropÛsito:  Devuelve el frame-rate.
// Fecha:      29/07/2004 12:43
//--------------------------------------------------------------------
float CTimer::GetFPS(void)
{
	return m_fFPS;
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::GetFrameTime
// PropÛsito:  Devuelve el tiempo cuando Frame() fue llamado por ˙ltima vez.
// Fecha:      29/07/2004 12:43
//--------------------------------------------------------------------
float CTimer::GetFrameTime(void)
{
	return m_fFrameTime;
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::GetDeltaTime
// PropÛsito:  Devuelve el tiempo que ha transcurrido entre dos llamadas a Frame().
// Fecha:      29/07/2004 12:43
//--------------------------------------------------------------------
float CTimer::GetDeltaTime(void)
{
	return m_fDeltaTime;
}


//--------------------------------------------------------------------
// FunciÛn:    CTimer::IsRunning
// PropÛsito:  Nos dice si el cronÛmetro est· en marcha o no.
// Fecha:      29/07/2004 12:43
//--------------------------------------------------------------------
bool CTimer::IsRunning(void)
{
	return m_bIsRunning;
}