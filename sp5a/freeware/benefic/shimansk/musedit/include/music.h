#ifdef __cplusplus
extern "C"
#endif

unsigned long far get_time( void );
void far set_time( unsigned long milliseconds );
void far install_music( void );
unsigned far get_music_pos( void );
void far mask_music( void );
void far unmask_music( void );
void far set_new_melody( void far *music );
void far uninstall_music( void );

void far my_sound( unsigned herts );
void far my_nosound( void );

unsigned far test_AT( void );

#ifdef __cplusplus
}
#endif
