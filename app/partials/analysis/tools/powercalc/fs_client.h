/*
 * fs_client.h
 *
 * Header file for clients of the file server.
 */

#ifndef _FS_CLIENT_H_
#define _FS_CLIENT_H_

#include <sys/types.h>
#include <netinet/in.h>

#include "fs_param.h"

/*
 * Initialize the client library.
 * The location of the file server is specified by (hostname, port).
 *
 * fs_clientinit returns 0 on success, -1 on failure.
 */
extern int fs_clientinit(const char *hostname, uint16_t port);

/*
 * Ask the file server for a new session.  The new session is returned
 * in *session_ptr.
 *
 * fs_session returns 0 on success, -1 on failure.  Possible failures include:
 *     username or password is invalid
 *     no more sessions available
 *
 * fs_session is thread safe.
 */
extern int fs_session(const char *username, const char *password,
                      unsigned int *session_ptr, unsigned int sequence);

/*
 * Read a block of data from the file specified by pathname.  offset specifies
 * the block to be read.  buf specifies where to store the data read from the
 * file.
 *
 * fs_readblock returns 0 on success, -1 on failure.  Possible failures include:
 *     pathname is invalid
 *     pathname does not exist, is not a file, or is not owned by username
 *     offset is out of range
 *     invalid session or sequence
 *     username or password is invalid
 *
 * fs_readblock is thread safe.
 */
extern int fs_readblock(const char *username, const char *password,
                   unsigned int session, unsigned int sequence,
                   const char *pathname, unsigned int offset, void *buf);

/*
 * Write a block of data to the file specified by pathname.  offset specifies
 * the block to be written.  offset may refer to an existing block in the file,
 * or it may refer to the block immediately after the current end of the file
 * (this is how files grow in size).  buf specifies where to get the data
 * that will be written to the file.
 *
 * fs_writeblock returns 0 on success, -1 on failure.  Possible failures include:
 *     pathname is invalid
 *     pathname does not exist, is not a file, or is not owned by username
 *     offset is out of range
 *     the disk or file is out of space
 *     invalid session or sequence
 *     username or password is invalid
 *
 * fs_writeblock is thread safe.
 */
extern int fs_writeblock(const char *username, const char *password,
                         unsigned int session, unsigned int sequence,
                         const char *pathname, unsigned int offset,
                         const void *buf);

/*
 * Create a new file or directory "pathname".  Type can be 'f' (file) or 'd'
 * (directory).
 *
 * fs_create returns 0 on success, -1 on failure.  Possible failures include:
 *     pathname is invalid
 *     pathname is in a directory not owned by username
 *     pathname already exists
 *     the disk or directory containing pathname is out of space
 *     invalid type
 *     invalid session or sequence
 *     username or password is invalid
 *
 * fs_create is thread safe.
 */
extern int fs_create(const char *username, const char *password,
                     unsigned int session, unsigned int sequence,
                     const char *pathname, char type);

/*
 * Delete the existing file or directory "pathname".
 *
 * fs_delete returns 0 on success, -1 on failure.  Possible failures include:
 *     pathname is invalid
 *     pathname is not owned by username
 *     pathname is in a directory not owned by username
 *     pathname does not exist
 *     pathname is a non-empty directory
 *     invalid session or sequence
 *     username or password is invalid
 *
 * fs_delete is thread safe.
 */
extern int fs_delete(const char *username, const char *password,
                     unsigned int session, unsigned int sequence,
                     const char *pathname);

#endif /* _FS_CLIENT_H_ */