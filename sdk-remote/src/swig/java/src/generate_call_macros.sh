#!/bin/sh

nb_of_args=16

cat <<EOF
/*
 * Copyright (C) 2010, Gostai S.A.S.
 *
 * This software is provided "as is" without warranty of any kind,
 * either expressed or implied, including but not limited to the
 * implied warranties of fitness for a particular purpose.
 *
 * See the LICENSE file for more information.
 */

/* This file was generated with $0, do not edit directly !*/

#ifndef CALL_MACROS_HH_
# define CALL_MACROS_HH_

EOF

create_var_list ()
{
    local i="$1"
    local var="$2"
    local arg=""
    if [ $i -gt 0 ]; then
	for j in $(seq 1 $(($i-1))); do
	    arg="$arg ${var}$j,"
	done
	arg="$arg ${var}$i"
    fi
    echo $arg
}

print_object_retrieving()
{
    local list=""
    for j in $(seq 1 $i); do
        list="$list const jvalue obj$j = arg_convert[$(($j - 1))]->convert(env_, uval$j);"
    done
    echo $list
}

print_object_destroying()
{
    local list=""
    for j in $(seq 1 $i); do
        list="$list arg_convert[$(($j - 1))]->destroy(env_);"
    done
    echo $list
}

for i in $(seq 0 $nb_of_args); do
    varlist=$(create_var_list $i "urbi::UValue uval")
    varlist2=$(create_var_list $i "obj")
    method_call="env_->Call##Type##MethodA(obj, mid, argument);"
    if test "x$varlist" != "x"; then
	varlist2="jvalue argument[] = { $varlist2 };"
    else
	method_call="env_->Call##Type##Method(obj, mid);"
    fi
    cat <<EOF
# define CALL_METHOD_$i(Name, Type, JavaType, error_val, ret, ret_snd, ret_ter)	\\
	JavaType call##Name##_$i ($varlist)				\\
	{								\\
	  if (!init_env ())						\\
	    return error_val;						\\
          if (env_->PushLocalFrame(16) < 0)				\\
          {								\\
            std::cerr << "Error pushing local frame" << std::endl;	\\
            throw std::runtime_error("Error pushing local frame");	\\
          }								\\
          $(print_object_retrieving)					\\
          $varlist2                                                     \\
	  ret $method_call						\\
          testForException();						\\
          ret_snd;							\\
          $(print_object_destroying)       				\\
          env_->PopLocalFrame(NULL);                                    \\
          ret_ter;							\\
	}
EOF
done


print_call_methods()
{
    local list=""
    for j in $(seq 0 $(($nb_of_args-1))); do
	list="$list CALL_METHOD_$j (Name, Type, JavaType, error_val, ret, ret_snd, ret_ter);"
    done
    echo $list
}

cat <<EOF
# define CALL_METHODS(Name, Type, JavaType, error_val, ret, ret_snd, ret_ter)		\\
  $(print_call_methods)								\\
  CALL_METHOD_$nb_of_args (Name, Type, JavaType, error_val, ret, ret_snd, ret_ter);



#endif
EOF